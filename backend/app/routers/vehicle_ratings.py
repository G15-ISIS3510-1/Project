from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List
from datetime import datetime
from pydantic import BaseModel

from app.db.base import get_db
from app.db.models import User, Vehicle, Booking
from app.schemas.vehicle_rating import (
    VehicleRatingResponse,
    VehicleRatingCreate,
    VehicleRatingUpdate,
    VehicleRatingWithDetails,
    TopRatedVehicleSearch,
    TopRatedVehicleResponse
)
from app.services.vehicle_rating_service import VehicleRatingService
from app.routers.users import get_current_user_from_token

router = APIRouter(prefix="/vehicle-ratings", tags=["vehicle-ratings"])


class PaginatedRatingResponse(BaseModel):
    """
    Respuesta paginada para calificaciones "planas".
    """
    items: List[VehicleRatingResponse]
    total: int
    skip: int
    limit: int


class PaginatedDetailedRatingResponse(BaseModel):
    """
    Respuesta paginada para calificaciones enriquecidas con info de vehículo/renter.
    """
    items: List[VehicleRatingWithDetails]
    total: int
    skip: int
    limit: int


@router.get("/", response_model=PaginatedRatingResponse)
async def list_ratings(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """
    Obtener lista paginada de calificaciones (todas las calificaciones del sistema).
    Soporta ?skip=&limit=
    """
    rating_service = VehicleRatingService(db)

    # vehicle_id=None => sin filtro (todas)
    data = await rating_service.get_ratings_by_vehicle(
        vehicle_id=None,
        skip=skip,
        limit=limit
    )

    # serializar cada rating simple con el schema que ya tienes
    serialized_items = [
        VehicleRatingResponse.from_orm(r) for r in data["items"]
    ]

    return {
        "items": serialized_items,
        "total": data["total"],
        "skip": data["skip"],
        "limit": data["limit"],
    }


@router.get("/{rating_id}", response_model=VehicleRatingResponse)
async def get_rating(
    rating_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Obtener una calificación específica por ID"""
    rating_service = VehicleRatingService(db)
    rating = await rating_service.get_rating_by_id(rating_id)

    if not rating:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Calificación no encontrada"
        )

    return rating


@router.get("/vehicle/{vehicle_id}", response_model=PaginatedDetailedRatingResponse)
async def get_ratings_by_vehicle(
    vehicle_id: str,
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db)
):
    """
    Obtener calificaciones de un vehículo específico,
    enriquecidas con datos del renter y del vehículo,
    en modo paginado (?skip=&limit=).
    """
    rating_service = VehicleRatingService(db)

    # Verificar que el vehículo existe
    result = await db.execute(select(Vehicle).where(Vehicle.vehicle_id == vehicle_id))
    vehicle = result.scalar_one_or_none()

    if not vehicle:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Vehículo no encontrado"
        )

    data = await rating_service.get_ratings_by_vehicle(
        vehicle_id=vehicle_id,
        skip=skip,
        limit=limit
    )

    # "items" aquí son VehicleRating ORM objects con .renter y .vehicle precargados
    detailed_items: List[VehicleRatingWithDetails] = []
    for rating in data["items"]:
        detailed_items.append(
            VehicleRatingWithDetails(
                rating_id=rating.rating_id,
                vehicle_id=rating.vehicle_id,
                booking_id=rating.booking_id,
                renter_id=rating.renter_id,
                rating=rating.rating,
                comment=rating.comment,
                created_at=rating.created_at,
                renter_name=rating.renter.name if rating.renter else None,
                vehicle_make=rating.vehicle.make if rating.vehicle else None,
                vehicle_model=rating.vehicle.model if rating.vehicle else None,
                vehicle_year=rating.vehicle.year if rating.vehicle else None,
            )
        )

    return {
        "items": detailed_items,
        "total": data["total"],
        "skip": data["skip"],
        "limit": data["limit"],
    }


@router.get("/vehicle/{vehicle_id}/stats")
async def get_vehicle_rating_stats(
    vehicle_id: str,
    db: AsyncSession = Depends(get_db)
):
    """Obtener estadísticas de calificación de un vehículo"""
    rating_service = VehicleRatingService(db)

    # Verificar que el vehículo existe
    result = await db.execute(select(Vehicle).where(Vehicle.vehicle_id == vehicle_id))
    vehicle = result.scalar_one_or_none()

    if not vehicle:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Vehículo no encontrado"
        )

    average_rating = await rating_service.get_average_rating_by_vehicle(vehicle_id)
    total_ratings = await rating_service.get_rating_count_by_vehicle(vehicle_id)

    return {
        "vehicle_id": vehicle_id,
        "average_rating": round(average_rating, 2) if average_rating else 0.0,
        "total_ratings": total_ratings,
        "make": vehicle.make,
        "model": vehicle.model,
        "year": vehicle.year
    }


@router.post("/", response_model=VehicleRatingResponse)
async def create_rating(
    rating_data: VehicleRatingCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Crear una nueva calificación"""
    rating_service = VehicleRatingService(db)

    # Verificar que el vehículo existe
    result = await db.execute(select(Vehicle).where(Vehicle.vehicle_id == rating_data.vehicle_id))
    vehicle = result.scalar_one_or_none()

    if not vehicle:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Vehículo no encontrado"
        )

    # Verificar que la reserva existe y pertenece al usuario
    result = await db.execute(
        select(Booking).where(
            Booking.booking_id == rating_data.booking_id,
            Booking.renter_id == current_user.user_id,
            Booking.vehicle_id == rating_data.vehicle_id
        )
    )
    booking = result.scalar_one_or_none()

    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Reserva no encontrada o no tienes permisos para calificar este vehículo"
        )

    # Verificar que la reserva está completada
    if booking.status != "completed":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Solo puedes calificar vehículos de reservas completadas"
        )

    try:
        rating = await rating_service.create_rating(rating_data, current_user.user_id)
        return rating
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )


@router.put("/{rating_id}", response_model=VehicleRatingResponse)
async def update_rating(
    rating_id: str,
    rating_update: VehicleRatingUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Actualizar una calificación existente"""
    rating_service = VehicleRatingService(db)

    # Verificar que la calificación existe y pertenece al usuario
    rating = await rating_service.get_rating_by_id(rating_id)
    if not rating:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Calificación no encontrada"
        )

    if rating.renter_id != current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Solo puedes actualizar tus propias calificaciones"
        )

    try:
        updated_rating = await rating_service.update_rating(rating_id, rating_update)
        return updated_rating
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )


@router.delete("/{rating_id}")
async def delete_rating(
    rating_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Eliminar una calificación"""
    rating_service = VehicleRatingService(db)

    # Verificar que la calificación existe y pertenece al usuario
    rating = await rating_service.get_rating_by_id(rating_id)
    if not rating:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Calificación no encontrada"
        )

    if rating.renter_id != current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Solo puedes eliminar tus propias calificaciones"
        )

    success = await rating_service.delete_rating(rating_id)

    if not success:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al eliminar la calificación"
        )

    return {"message": "Calificación eliminada correctamente"}


@router.post("/search/top-rated", response_model=List[TopRatedVehicleResponse])
async def search_top_rated_vehicles(
    search_params: TopRatedVehicleSearch,
    db: AsyncSession = Depends(get_db)
):
    """
    Buscar los vehículos con mayor calificación disponibles para fechas y ubicación específicas.
    (esta ruta ya tenía su `limit` propio en el body, la dejamos igual)
    """
    rating_service = VehicleRatingService(db)

    try:
        # Validar formato de fechas
        datetime.fromisoformat(search_params.start_ts.replace('Z', '+00:00'))
        datetime.fromisoformat(search_params.end_ts.replace('Z', '+00:00'))
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Formato de fecha inválido. Use ISO format (ej: 2024-01-01T09:00:00Z)"
        )

    try:
        vehicles = await rating_service.get_top_rated_vehicles(
            start_ts=search_params.start_ts,
            end_ts=search_params.end_ts,
            lat=search_params.lat,
            lng=search_params.lng,
            radius_km=search_params.radius_km,
            limit=search_params.limit,
            min_rating=search_params.min_rating
        )

        return [TopRatedVehicleResponse(**vehicle) for vehicle in vehicles]

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error en la búsqueda: {str(e)}"
        )
