from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.base import get_db
from app.db.models import User, Vehicle, Pricing
from app.schemas.vehicle import VehicleResponse, VehicleCreate, VehicleUpdate

from app.core.security import get_current_user_token
from app.services.vehicle_service import VehicleService
from app.routers.users import get_current_user_from_token
from typing import List, Optional
from pydantic import BaseModel

from fastapi import UploadFile, File
import shutil
from pathlib import Path
from sqlalchemy import select, update, or_

router = APIRouter(prefix="/vehicles", tags=["vehicles"])


# ---------- Pydantic response wrappers for pagination ----------

class PaginatedVehicleResponse(BaseModel):
    items: List[VehicleResponse]
    total: int
    skip: int
    limit: int


class VehicleWithPricingItem(BaseModel):
    id: str
    brand: str
    model: str
    year: int
    transmission: str
    imageUrl: Optional[str]
    status: str
    dailyRate: float
    currency: str
    minDays: int
    maxDays: Optional[int]
    lat: Optional[float] = None
    lng: Optional[float] = None


class PaginatedVehicleWithPricingResponse(BaseModel):
    items: List[VehicleWithPricingItem]
    total: int
    skip: int
    limit: int


# ---------- Routes ----------

from app.utils.feature_tracking_decorator import track_feature_usage

@router.get("/", response_model=PaginatedVehicleResponse)
@track_feature_usage("vehicle_list_view")
async def get_vehicles(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """
    Obtiene lista paginada de vehículos.
    Devuelve { items, total, skip, limit }.
    """
    vehicle_service = VehicleService(db)
    data = await vehicle_service.get_vehicles(skip=skip, limit=limit)

    serialized_items = [
        VehicleResponse.from_orm(v) for v in data["items"]
    ]

    return {
        "items": serialized_items,
        "total": data["total"],
        "skip": data["skip"],
        "limit": data["limit"],
    }


@router.get("/active", response_model=PaginatedVehicleResponse)
async def get_active_vehicles(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
):
    """
    Obtiene lista paginada de vehículos con status 'active'.
    Sin requerir autenticación.
    Devuelve { items, total, skip, limit }.
    """
    result = await db.execute(
        select(Vehicle).where(Vehicle.status.in_(["active"]))
    )
    all_active = result.scalars().all()

    total = len(all_active)

    # Paginación en memoria (para no complicar el count con filtros)
    page_slice = all_active[skip: skip + limit]

    serialized_items = [
        VehicleResponse.from_orm(v) for v in page_slice
    ]

    if not serialized_items:
        # seguimos respondiendo 200 pero podría ser 404 antes;
        # mantenemos la semántica vieja solo si realmente quieres eso.
        # En tu código anterior lanzabas 404 si no había vehículos.
        # Para no romper clientes que esperan 404, conservamos esa lógica:
        raise HTTPException(
            status_code=404,
            detail="No hay vehículos disponibles"
        )

    return {
        "items": serialized_items,
        "total": total,
        "skip": skip,
        "limit": limit,
    }


@router.get("/active-with-pricing", response_model=PaginatedVehicleWithPricingResponse)
async def get_active_vehicles_with_pricing(
    search: Optional[str] = None,
    category: Optional[str] = None,
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db)
):
    """
    Obtiene vehículos activos con su información de pricing,
    con filtros opcionales y paginación.
    Devuelve { items, total, skip, limit }.
    """

    # Construir query base
    query = select(Vehicle).where(Vehicle.status == "active")

    # Filtro por texto libre (marca/modelo)
    if search:
        search_filter = or_(
            Vehicle.make.ilike(f"%{search}%"),
            Vehicle.model.ilike(f"%{search}%")
        )
        query = query.where(search_filter)

    # Filtro por categoría
    if category:
        category_keywords = {
            "SUVs": ["SUV", "4Runner", "Explorer", "Wrangler"],
            "Trucks": ["Truck", "F-150", "Silverado", "Tacoma"],
            "Vans": ["Van", "Caravan", "Transit"],
            "Minivans": ["Minivan", "Odyssey", "Sienna"],
            "Luxury": ["Mercedes", "BMW", "Audi", "Lexus", "Porsche"],
            "Cars": []  # default / catch-all
        }

        if category in category_keywords and category != "Cars":
            keywords = category_keywords[category]
            category_filter = or_(
                *[Vehicle.model.ilike(f"%{kw}%") for kw in keywords],
                *[Vehicle.make.ilike(f"%{kw}%") for kw in keywords]
            )
            query = query.where(category_filter)

    # Ejecutar query completa para poder contar y luego paginar
    result = await db.execute(query)
    filtered_active = result.scalars().all()

    total = len(filtered_active)

    # Paginación en memoria
    page_slice = filtered_active[skip: skip + limit]

    # Armar respuesta con pricing
    response_items: List[VehicleWithPricingItem] = []
    for vehicle in page_slice:
        pricing_result = await db.execute(
            select(Pricing).where(Pricing.vehicle_id == vehicle.vehicle_id)
        )
        pricing = pricing_result.scalar_one_or_none()

        response_items.append(
            VehicleWithPricingItem(
                id=vehicle.vehicle_id,
                brand=vehicle.make,
                model=vehicle.model,
                year=vehicle.year,
                transmission=vehicle.transmission,
                imageUrl=vehicle.photo_url,
                status=vehicle.status,
                dailyRate=pricing.daily_price if pricing else 0.0,
                currency=pricing.currency if pricing else "USD",
                minDays=pricing.min_days if pricing else 1,
                maxDays=pricing.max_days if pricing else None,
                lat=vehicle.lat,
                lng=vehicle.lng
            )
        )

    return {
        "items": response_items,
        "total": total,
        "skip": skip,
        "limit": limit,
    }


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


@router.get("/owner/{owner_id}", response_model=PaginatedVehicleResponse)
async def get_vehicles_by_owner(
    owner_id: str,
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """
    Obtiene vehículos de un propietario específico con paginación.
    Devuelve { items, total, skip, limit }.
    """
    vehicle_service = VehicleService(db)
    data = await vehicle_service.get_vehicles_by_owner(
        owner_id=owner_id,
        skip=skip,
        limit=limit
    )

    serialized_items = [
        VehicleResponse.from_orm(v) for v in data["items"]
    ]

    return {
        "items": serialized_items,
        "total": data["total"],
        "skip": data["skip"],
        "limit": data["limit"],
    }


@router.post("/", response_model=VehicleResponse)
@track_feature_usage("vehicle_registration")
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
