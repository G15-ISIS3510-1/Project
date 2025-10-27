from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List, Optional
from datetime import datetime
from pydantic import BaseModel

from app.db.base import get_db
from app.db.models import User, Vehicle, InsurancePlan, BookingStatus
from app.schemas.booking import BookingCreate, BookingUpdate, BookingResponse
from app.services.booking_service import BookingService
from app.routers.users import get_current_user_from_token

router = APIRouter(tags=["bookings"])


class PaginatedBookingResponse(BaseModel):
    items: List[BookingResponse]
    total: int
    skip: int
    limit: int

# -------------------------
# Helpers
# -------------------------
async def _get_vehicle(db: AsyncSession, vehicle_id: str) -> Optional[Vehicle]:
    res = await db.execute(select(Vehicle).where(Vehicle.vehicle_id == vehicle_id))
    return res.scalar_one_or_none()

async def _get_user(db: AsyncSession, user_id: str) -> Optional[User]:
    res = await db.execute(select(User).where(User.user_id == user_id))
    return res.scalar_one_or_none()

async def _get_insurance(db: AsyncSession, insurance_plan_id: str) -> Optional[InsurancePlan]:
    res = await db.execute(select(InsurancePlan).where(InsurancePlan.insurance_plan_id == insurance_plan_id))
    return res.scalar_one_or_none()

def _validate_datetimes(start_ts: datetime, end_ts: datetime):
    if end_ts <= start_ts:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="end_ts debe ser mayor a start_ts",
        )

# -------------------------
# Endpoints
# -------------------------

# Root collection — POST
@router.post("", response_model=BookingResponse, status_code=status.HTTP_201_CREATED)
async def create_booking(
    payload: BookingCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """
    Crear una reserva.
    """
    _validate_datetimes(payload.start_ts, payload.end_ts)

    vehicle = await _get_vehicle(db, payload.vehicle_id)
    if not vehicle:
        raise HTTPException(status_code=404, detail="Vehículo no encontrado")

    if vehicle.owner_id != payload.host_id:
        raise HTTPException(status_code=400, detail="host_id no coincide con el propietario del vehículo")

    if payload.renter_id != current_user.user_id:
        raise HTTPException(status_code=403, detail="Solo puedes crear reservas como el renter autenticado")

    host = await _get_user(db, payload.host_id)
    if not host:
        raise HTTPException(status_code=404, detail="Host no encontrado")

    renter = await _get_user(db, payload.renter_id)
    if not renter:
        raise HTTPException(status_code=404, detail="Renter no encontrado")

    if payload.insurance_plan_id:
        plan = await _get_insurance(db, payload.insurance_plan_id)
        if not plan or not plan.active:
            raise HTTPException(status_code=400, detail="Plan de seguro inválido o inactivo")

    svc = BookingService(db)
    try:
        booking = await svc.create_booking(payload)
        return booking
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

# Trailing-slash alias for POST (hidden)
@router.post("/", response_model=BookingResponse, status_code=status.HTTP_201_CREATED, include_in_schema=False)
async def create_booking_alias(
    payload: BookingCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    return await create_booking(payload, db, current_user)

# Root collection — GET
@router.get("", response_model=PaginatedBookingResponse)
async def list_my_bookings(
    skip: int = 0,
    limit: int = 100,
    status_filter: Optional[BookingStatus] = Query(None, description="Filtra por estado"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """
    Lista las reservas donde el usuario autenticado participa (como renter o host).
    Paginado y con filtro opcional por estado.
    """
    svc = BookingService(db)
    data = await svc.get_bookings(
        for_user_id=current_user.user_id,
        status_filter=status_filter,
        skip=skip,
        limit=limit,
    )
    serialized = [BookingResponse.from_orm(b) for b in data["items"]]
    return {
        "items": serialized,
        "total": data["total"],
        "skip": data["skip"],
        "limit": data["limit"],
    }

# Trailing-slash alias for GET (hidden)
@router.get("/", response_model=PaginatedBookingResponse, include_in_schema=False)
async def list_my_bookings_alias(
    skip: int = 0,
    limit: int = 100,
    status_filter: Optional[BookingStatus] = Query(None),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    return await list_my_bookings(skip, limit, status_filter, db, current_user)

@router.get("/vehicle/{vehicle_id}", response_model=PaginatedBookingResponse)
async def get_bookings_by_vehicle(
    vehicle_id: str,
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """
    Listar reservas de un vehículo (paginado).
    Solo el propietario (host) puede ver todas; el renter solo ve sus reservas.
    """
    vehicle = await _get_vehicle(db, vehicle_id)
    if not vehicle:
        raise HTTPException(status_code=404, detail="Vehículo no encontrado")

    svc = BookingService(db)
    data = await svc.get_bookings_by_id_vehicle(vehicle_id, skip=skip, limit=limit)

    items = data["items"]
    if vehicle.owner_id != current_user.user_id:
        items = [b for b in items if b.renter_id == current_user.user_id]

    serialized = [BookingResponse.from_orm(b) for b in items]
    return {
        "items": serialized,
        # Nota: total refleja los visibles tras el filtro de permisos
        "total": len(items),
        "skip": skip,
        "limit": limit,
    }

@router.get("/user/{user_id}", response_model=PaginatedBookingResponse)
async def get_bookings_by_user(
    user_id: str,
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """
    Listar reservas asociadas a un usuario (paginado).
    - Si pides las tuyas: ok.
    - Si pides las de otro, se filtran para mostrar solo las donde seas host.
    """
    user = await _get_user(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    svc = BookingService(db)
    data = await svc.get_bookings_by_id_user(user_id, skip=skip, limit=limit)

    items = data["items"]
    if user_id != current_user.user_id:
        items = [b for b in items if b.host_id == current_user.user_id]

    serialized = [BookingResponse.from_orm(b) for b in items]
    return {
        "items": serialized,
        "total": len(items),
        "skip": skip,
        "limit": limit,
    }

@router.get("/insurance/{insurance_plan_id}", response_model=PaginatedBookingResponse)
async def get_bookings_by_insurance(
    insurance_plan_id: str,
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """Listar reservas por plan de seguros (paginado; útil para reportes del host/administrador)."""
    plan = await _get_insurance(db, insurance_plan_id)
    if not plan:
        raise HTTPException(status_code=404, detail="Plan de seguro no encontrado")

    svc = BookingService(db)
    data = await svc.get_bookings_by_id_insurance_plan(insurance_plan_id, skip=skip, limit=limit)

    items = [b for b in data["items"] if b.host_id == current_user.user_id]
    serialized = [BookingResponse.from_orm(b) for b in items]
    return {
        "items": serialized,
        "total": len(items),
        "skip": skip,
        "limit": limit,
    }

@router.get("/{booking_id}", response_model=BookingResponse)
async def get_booking(
    booking_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """Obtener una reserva por ID (solo si eres host o renter en esa reserva)."""
    svc = BookingService(db)
    booking = await svc.get_booking(booking_id)
    if not booking:
        raise HTTPException(status_code=404, detail="Reserva no encontrada")
    if current_user.user_id not in (booking.renter_id, booking.host_id):
        raise HTTPException(status_code=403, detail="No tienes acceso a esta reserva")
    return booking

@router.put("/{booking_id}", response_model=BookingResponse)
async def update_booking(
    booking_id: str,
    payload: BookingUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """
    Actualizar una reserva.
    """
    if payload.start_ts and payload.end_ts:
        _validate_datetimes(payload.start_ts, payload.end_ts)

    svc = BookingService(db)
    booking = await svc.get_booking(booking_id)
    if not booking:
        raise HTTPException(status_code=404, detail="Reserva no encontrada")
    if current_user.user_id not in (booking.renter_id, booking.host_id):
        raise HTTPException(status_code=403, detail="No tienes acceso para actualizar esta reserva")

    try:
        updated = await svc.update_booking(booking_id, payload)
        return updated
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/{booking_id}")
async def delete_booking(
    booking_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """
    Eliminar una reserva.
    Regla: solo host o renter de esa reserva.
    """
    svc = BookingService(db)
    booking = await svc.get_booking(booking_id)
    if not booking:
        raise HTTPException(status_code=404, detail="Reserva no encontrada")
    if current_user.user_id not in (booking.renter_id, booking.host_id):
        raise HTTPException(status_code=403, detail="No tienes acceso para eliminar esta reserva")
    ok = await svc.delete_booking(booking_id)
    if not ok:
        raise HTTPException(status_code=500, detail="No se pudo eliminar la reserva")
    return {"message": "Reserva eliminada correctamente"}

# -------------------------
# (Opcionales) bulk por entidad
# -------------------------

@router.delete("/vehicle/{vehicle_id}")
async def delete_bookings_by_vehicle(
    vehicle_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """Eliminar TODAS las reservas de un vehículo (solo el propietario)."""
    vehicle = await _get_vehicle(db, vehicle_id)
    if not vehicle:
        raise HTTPException(status_code=404, detail="Vehículo no encontrado")
    if vehicle.owner_id != current_user.user_id:
        raise HTTPException(status_code=403, detail="Solo el propietario puede eliminar las reservas de su vehículo")

    svc = BookingService(db)
    deleted = await svc.delete_booking_by_id_vehicle(vehicle_id)
    return {"message": f"Se eliminaron {deleted} reservas del vehículo", "deleted_count": deleted}

@router.delete("/user/{user_id}")
async def delete_bookings_by_user(
    user_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """Eliminar reservas asociadas a un usuario (solo el propio usuario, por seguridad)."""
    if user_id != current_user.user_id:
        raise HTTPException(status_code=403, detail="No autorizado para eliminar reservas de otro usuario")
    svc = BookingService(db)
    deleted = await svc.delete_booking_by_id_user(user_id)
    return {"message": f"Se eliminaron {deleted} reservas del usuario", "deleted_count": deleted}

@router.delete("/insurance/{insurance_plan_id}")
async def delete_bookings_by_insurance(
    insurance_plan_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """Eliminar reservas por plan de seguro (ajusta permisos según tu modelo)."""
    svc = BookingService(db)
    deleted = await svc.delete_booking_by_id_insurance_plan(insurance_plan_id)
    return {"message": f"Se eliminaron {deleted} reservas asociadas al plan", "deleted_count": deleted}
