from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List, Optional
from datetime import datetime

from app.db.base import get_db
from app.db.models import User, Vehicle
from app.schemas.vehicle_availability import (
    VehicleAvailabilityResponse, 
    VehicleAvailabilityCreate, 
    VehicleAvailabilityUpdate
)
from app.services.vehicle_availability_service import VehicleAvailabilityService
from app.routers.users import get_current_user_from_token

router = APIRouter(tags=["vehicle-availability"])

@router.get("/", response_model=List[VehicleAvailabilityResponse])
async def list_availabilities(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Obtener lista de disponibilidades de vehículos"""
    availability_service = VehicleAvailabilityService(db)
    availabilities = await availability_service.get_availabilities(skip=skip, limit=limit)
    return availabilities

@router.get("/{availability_id}", response_model=VehicleAvailabilityResponse)
async def get_availability(
    availability_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Obtener una disponibilidad específica por ID"""
    availability_service = VehicleAvailabilityService(db)
    availability = await availability_service.get_availability_by_id(availability_id)
    
    if not availability:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Disponibilidad no encontrada"
        )
    
    return availability

@router.get("/vehicle/{vehicle_id}", response_model=List[VehicleAvailabilityResponse])
async def get_availabilities_by_vehicle(
    vehicle_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Obtener todas las disponibilidades de un vehículo específico"""
    availability_service = VehicleAvailabilityService(db)
    
    # Verificar que el vehículo existe y pertenece al usuario
    result = await db.execute(select(Vehicle).where(Vehicle.vehicle_id == vehicle_id))
    vehicle = result.scalar_one_or_none()
    
    if not vehicle:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Vehículo no encontrado"
        )
    
    availabilities = await availability_service.get_availabilities_by_vehicle(vehicle_id)
    return availabilities

@router.get("/search/available", response_model=List[VehicleAvailabilityResponse])
async def search_available_vehicles(
    start_ts: str = Query(..., description="Fecha y hora de inicio (ISO format)"),
    end_ts: str = Query(..., description="Fecha y hora de fin (ISO format)"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Buscar vehículos disponibles en un rango de fechas"""
    availability_service = VehicleAvailabilityService(db)
    
    try:
        # Validar formato de fechas
        datetime.fromisoformat(start_ts.replace('Z', '+00:00'))
        datetime.fromisoformat(end_ts.replace('Z', '+00:00'))
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Formato de fecha inválido. Use ISO format (ej: 2024-01-01T09:00:00Z)"
        )
    
    availabilities = await availability_service.get_available_vehicles(start_ts, end_ts)
    return availabilities

@router.post("/", response_model=VehicleAvailabilityResponse)
async def create_availability(
    availability_data: VehicleAvailabilityCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Crear una nueva disponibilidad de vehículo"""
    availability_service = VehicleAvailabilityService(db)
    
    # Verificar que el vehículo existe y pertenece al usuario
    result = await db.execute(select(Vehicle).where(Vehicle.vehicle_id == availability_data.vehicle_id))
    vehicle = result.scalar_one_or_none()
    
    if not vehicle:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Vehículo no encontrado"
        )
    
    if vehicle.owner_id != current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Solo puedes crear disponibilidades para tus propios vehículos"
        )
    
    try:
        availability = await availability_service.create_availability(availability_data)
        return availability
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.put("/{availability_id}", response_model=VehicleAvailabilityResponse)
async def update_availability(
    availability_id: str,
    availability_update: VehicleAvailabilityUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Actualizar una disponibilidad existente"""
    availability_service = VehicleAvailabilityService(db)
    
    # Verificar que la disponibilidad existe y el vehículo pertenece al usuario
    availability = await availability_service.get_availability_by_id(availability_id)
    if not availability:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Disponibilidad no encontrada"
        )
    
    result = await db.execute(select(Vehicle).where(Vehicle.vehicle_id == availability.vehicle_id))
    vehicle = result.scalar_one_or_none()
    
    if not vehicle or vehicle.owner_id != current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Solo puedes actualizar las disponibilidades de tus propios vehículos"
        )
    
    try:
        updated_availability = await availability_service.update_availability(availability_id, availability_update)
        return updated_availability
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.delete("/{availability_id}")
async def delete_availability(
    availability_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Eliminar una disponibilidad"""
    availability_service = VehicleAvailabilityService(db)
    
    # Verificar que la disponibilidad existe y el vehículo pertenece al usuario
    availability = await availability_service.get_availability_by_id(availability_id)
    if not availability:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Disponibilidad no encontrada"
        )
    
    result = await db.execute(select(Vehicle).where(Vehicle.vehicle_id == availability.vehicle_id))
    vehicle = result.scalar_one_or_none()
    
    if not vehicle or vehicle.owner_id != current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Solo puedes eliminar las disponibilidades de tus propios vehículos"
        )
    
    success = await availability_service.delete_availability(availability_id)
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al eliminar la disponibilidad"
        )
    
    return {"message": "Disponibilidad eliminada correctamente"}

@router.delete("/vehicle/{vehicle_id}")
async def delete_availabilities_by_vehicle(
    vehicle_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Eliminar todas las disponibilidades de un vehículo"""
    availability_service = VehicleAvailabilityService(db)
    
    # Verificar que el vehículo existe y pertenece al usuario
    result = await db.execute(select(Vehicle).where(Vehicle.vehicle_id == vehicle_id))
    vehicle = result.scalar_one_or_none()
    
    if not vehicle:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Vehículo no encontrado"
        )
    
    if vehicle.owner_id != current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Solo puedes eliminar las disponibilidades de tus propios vehículos"
        )
    
    deleted_count = await availability_service.delete_availabilities_by_vehicle(vehicle_id)
    
    return {
        "message": f"Se eliminaron {deleted_count} disponibilidades del vehículo",
        "deleted_count": deleted_count
    }
