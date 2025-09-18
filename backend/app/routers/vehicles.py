from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.base import get_db
from app.db.models import User, Vehicle
from app.schemas.vehicle import VehicleResponse, VehicleCreate, VehicleUpdate

from app.core.security import get_current_user_token
from app.services.vehicle_service import VehicleService
from app.routers.users import get_current_user_from_token
from typing import List

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