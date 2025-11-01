from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.base import get_db
from app.db.models import User, Vehicle, Pricing
from app.schemas.vehicle import VehicleResponse, VehicleCreate, VehicleUpdate

from app.core.security import get_current_user_token
from app.services.vehicle_service import VehicleService
from app.routers.users import get_current_user_from_token
from typing import List

from fastapi import UploadFile, File
import shutil
from pathlib import Path
from sqlalchemy import select, update

from typing import Optional
from sqlalchemy import or_

router = APIRouter(prefix="/vehicles", tags=["vehicles"])

@router.get("/", response_model=List[VehicleResponse])
async def get_vehicles(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Obtiene lista de vehículos"""
    vehicle_service = VehicleService(db)
    vehicles = await vehicle_service.get_vehicles(skip=skip, limit=limit)
    return vehicles


@router.get("/active", response_model=List[VehicleResponse])
async def get_active_vehicles(db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(Vehicle).where(Vehicle.status.in_(["active"]))  
    )
    vehicles = result.scalars().all()
    
    if not vehicles:
        raise HTTPException(status_code=404, detail="No hay vehículos disponibles")
    
    return vehicles

@router.get("/active-with-pricing", response_model=List[dict])
async def get_active_vehicles_with_pricing(
    search: Optional[str] = None,
    category: Optional[str] = None, 
    db: AsyncSession = Depends(get_db)
):
    """Obtiene vehículos activos con sus precios (con búsqueda y filtros)"""
    
    
    query = select(Vehicle).where(Vehicle.status == "active")
    
    
    if search:
        search_filter = or_(
            Vehicle.make.ilike(f"%{search}%"),
            Vehicle.model.ilike(f"%{search}%")
        )
        query = query.where(search_filter)
    
    
    if category:
        
        category_keywords = {
            "SUVs": ["SUV", "4Runner", "Explorer", "Wrangler"],
            "Trucks": ["Truck", "F-150", "Silverado", "Tacoma"],
            "Vans": ["Van", "Caravan", "Transit"],
            "Minivans": ["Minivan", "Odyssey", "Sienna"],
            "Luxury": ["Mercedes", "BMW", "Audi", "Lexus", "Porsche"],
            "Cars": []  
        }
        
        if category in category_keywords and category != "Cars":
            keywords = category_keywords[category]
            category_filter = or_(
                *[Vehicle.model.ilike(f"%{kw}%") for kw in keywords],
                *[Vehicle.make.ilike(f"%{kw}%") for kw in keywords]
            )
            query = query.where(category_filter)
    
    result = await db.execute(query)
    vehicles = result.scalars().all()
    
    if not vehicles:
        return []  
    
    response = []
    for vehicle in vehicles:
        pricing_result = await db.execute(
            select(Pricing).where(Pricing.vehicle_id == vehicle.vehicle_id)
        )
        pricing = pricing_result.scalar_one_or_none()
        
        response.append({
            "id": vehicle.vehicle_id,
            "brand": vehicle.make,
            "model": vehicle.model,
            "year": vehicle.year,
            "transmission": vehicle.transmission,
            "imageUrl": vehicle.photo_url,
            "status": vehicle.status,
            "dailyRate": pricing.daily_price if pricing else 0.0,
            "currency": pricing.currency if pricing else "USD",
            "minDays": pricing.min_days if pricing else 1,
            "maxDays": pricing.max_days if pricing else None
        })
    
    return response

@router.get("/{vehicle_id}", response_model=VehicleResponse)
async def get_vehicle(
    vehicle_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Obtiene un vehículo específico por ID"""
    vehicle_service = VehicleService(db)
    vehicle = await vehicle_service.get_vehicle_by_id(vehicle_id)
    
    if not vehicle:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Vehículo no encontrado"
        )
    
    return vehicle

@router.get("/owner/{owner_id}", response_model=List[VehicleResponse])
async def get_vehicles_by_owner(
    owner_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Obtiene vehículos de un propietario específico"""
    vehicle_service = VehicleService(db)
    vehicles = await vehicle_service.get_vehicles_by_owner(owner_id)
    return vehicles




@router.post("/", response_model=VehicleResponse)
async def create_vehicle(
    vehicle_data: VehicleCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Crea un nuevo vehículo"""
    vehicle_service = VehicleService(db)
    
    try:
        vehicle = await vehicle_service.create_vehicle(vehicle_data, current_user.user_id)
        return vehicle
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    
@router.post("/{vehicle_id}/upload-photo")
async def upload_vehicle_photo(
    vehicle_id: str,
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Sube una foto para un vehículo"""
    vehicle_service = VehicleService(db)
    vehicle = await vehicle_service.get_vehicle_by_id(vehicle_id)
    
    if not vehicle:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Vehículo no encontrado"
        )
    
    if vehicle.owner_id != current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Solo puedes subir fotos a tus propios vehículos"
        )
    
    # Crear directorio si no existe
    upload_dir = Path("static/vehicles")
    upload_dir.mkdir(parents=True, exist_ok=True)
    
    # Guardar archivo
    file_extension = file.filename.split(".")[-1] if "." in file.filename else "jpg"
    file_path = upload_dir / f"{vehicle_id}.{file_extension}"
    
    with file_path.open("wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    # Actualizar URL en BD
    photo_url = f"/static/vehicles/{vehicle_id}.{file_extension}"
    
    await db.execute(
        update(Vehicle)
        .where(Vehicle.vehicle_id == vehicle_id)
        .values(photo_url=photo_url)
    )
    await db.commit()
    
    return {"photo_url": photo_url, "message": "Foto subida exitosamente"}

@router.put("/{vehicle_id}", response_model=VehicleResponse)
async def update_vehicle(
    vehicle_id: str,
    vehicle_update: VehicleUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Actualiza un vehículo"""
    vehicle_service = VehicleService(db)
    
    # Verificar que el vehículo pertenece al usuario actual
    vehicle = await vehicle_service.get_vehicle_by_id(vehicle_id)
    if not vehicle:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Vehículo no encontrado"
        )
    
    if vehicle.owner_id != current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Solo puedes actualizar tus propios vehículos"
        )
    
    try:
        updated_vehicle = await vehicle_service.update_vehicle(vehicle_id, vehicle_update)
        return updated_vehicle
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.delete("/{vehicle_id}")
async def delete_vehicle(
    vehicle_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Elimina un vehículo (soft delete)"""
    vehicle_service = VehicleService(db)
    
    # Verificar que el vehículo pertenece al usuario actual
    vehicle = await vehicle_service.get_vehicle_by_id(vehicle_id)
    if not vehicle:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Vehículo no encontrado"
        )
    
    if vehicle.owner_id != current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Solo puedes eliminar tus propios vehículos"
        )
    
    success = await vehicle_service.delete_vehicle(vehicle_id)
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al eliminar el vehículo"
        )
    
    return {"message": "Vehículo eliminado correctamente"}