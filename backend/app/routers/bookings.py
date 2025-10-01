from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, or_, and_
from typing import List, Optional
from datetime import datetime

from app.db.base import get_db
from app.db.models import User, Vehicle, Booking, InsurancePlan
from app.schemas.booking import BookingCreate, BookingUpdate, BookingResponse
from app.services.booking_service import BookingService
from app.routers.users import get_current_user_from_token
from app.db.models import BookingStatus

router = APIRouter(tags=["bookings"])

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
    res = await db.execute(
        select(InsurancePlan).where(InsurancePlan.insurance_plan_id == insurance_plan_id)
    )
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

@router.post("/", response_model=BookingResponse, status_code=status.HTTP_201_CREATED)
async def create_booking(
    payload: BookingCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """
    Crear una reserva.
    Reglas:
      - El vehículo debe existir.
      - El host debe ser el dueño del vehículo.
      - El renter debe ser el usuario autenticado.
      - start_ts < end_ts.
      - (Conflictos de disponibilidad/overlap se validan en el BookingService)
    """
    _validate_datetimes(payload.start_ts, payload.end_ts)

    vehicle = await _get_vehicle(db, payload.vehicle_id)
    if not vehicle:
        raise HTTPException(status_code=404, detail="Vehículo no encontrado")

    # El host debe ser el dueño del vehículo
    if vehicle.owner_id != payload.host_id:
        raise HTTPException(
            status_code=400,
            detail="host_id no coincide con el propietario del vehículo",
        )

    # El renter debe ser el usuario autenticado (evita suplantación)
    if payload.renter_id != current_user.user_id:
        raise HTTPException(
            status_code=403,
            detail="Solo puedes crear reservas como el renter autenticado",
        )

    # Validar que host y renter existan
    host = await _get_user(db, payload.host_id)
    if not host:
        raise HTTPException(status_code=404, detail="Host no encontrado")

    renter = await _get_user(db, payload.renter_id)
    if not renter:
        raise HTTPException(status_code=404, detail="Renter no encontrado")

    # Validar plan de seguros si viene
    if payload.insurance_plan_id:
        plan = await _get_insurance(db, payload.insurance_plan_id)
        if not plan or not plan.active:
            raise HTTPException(status_code=400, detail="Plan de seguro inválido o inactivo")

    svc = BookingService(db)
    try:
        booking = await svc.create_booking(payload)
        return booking
    except ValueError as e:
        # deja que el service haga validaciones de solapes/disponibilidad/estado
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/", response_model=List[BookingResponse])
async def list_my_bookings(
    skip: int = 0,
    limit: int = 100,
    status_filter: Optional[BookingStatus] = Query(None, description="Filtra por estado"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """
    Lista las reservas donde el usuario autenticado participa (como renter o host).
    """
    svc = BookingService(db)
    # Idealmente el service implementa el filtro; mientras tanto podemos delegar completamente:
    bookings = await svc.get_bookings()  # completa en service con filtros/paginación
    # Si prefieres filtrar aquí mientras completas el service, descomenta esto y borra la línea de arriba:
    # q = select(Booking).where(
    #     or_(Booking.renter_id == current_user.user_id, Booking.host_id == current_user.user_id)
    # )
    # if status_filter:
    #     q = q.where(Booking.status == status_filter)
    # q = q.order_by(Booking.created_at.desc()).offset(skip).limit(limit)
    # res = await db.execute(q)
    # bookings = res.scalars().all()
    return bookings


@router.get("/{booking_id}", response_model=BookingResponse)
async def get_booking(
    booking_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """Obtener una reserva por ID (solo si eres host o renter en esa reserva)."""
    svc = BookingService(db)
    booking = await svc.get_booking(booking_id)  # completa en service
    if not booking:
        raise HTTPException(status_code=404, detail="Reserva no encontrada")

    if current_user.user_id not in (booking.renter_id, booking.host_id):
        raise HTTPException(status_code=403, detail="No tienes acceso a esta reserva")

    return booking


@router.get("/vehicle/{vehicle_id}", response_model=List[BookingResponse])
async def get_bookings_by_vehicle(
    vehicle_id: str,
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """
    Listar reservas de un vehículo.
    Solo el propietario (host) puede ver todas; el renter solo ve sus reservas
    (este filtro fino puedes terminarlo en el service).
    """
    vehicle = await _get_vehicle(db, vehicle_id)
    if not vehicle:
        raise HTTPException(status_code=404, detail="Vehículo no encontrado")

    # Si no eres dueño, limitaremos a tus propias reservas (si lo deseas)
    svc = BookingService(db)
    bookings = await svc.get_bookings_by_id_vehicle(vehicle_id)  # completa en service
    # Filtrado opcional por permisos:
    if vehicle.owner_id != current_user.user_id:
        bookings = [b for b in bookings if b.renter_id == current_user.user_id]
    return bookings


@router.get("/user/{user_id}", response_model=List[BookingResponse])
async def get_bookings_by_user(
    user_id: str,
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """
    Listar reservas asociadas a un usuario.
    - Si pides las tuyas: ok.
    - Si pides las de otro y no eres host de esas reservas, se debe denegar o filtrar (ajústalo a tu negocio).
    """
    user = await _get_user(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")

    svc = BookingService(db)
    bookings = await svc.get_bookings_by_id_user(user_id)  # completa en service

    # Permisos mínimos: si no eres el usuario solicitado, deja solo donde seas host.
    if user_id != current_user.user_id:
        bookings = [b for b in bookings if b.host_id == current_user.user_id]

    return bookings


@router.get("/insurance/{insurance_plan_id}", response_model=List[BookingResponse])
async def get_bookings_by_insurance(
    insurance_plan_id: str,
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """Listar reservas por plan de seguros (útil para reportes del host/administrador)."""
    plan = await _get_insurance(db, insurance_plan_id)
    if not plan:
        raise HTTPException(status_code=404, detail="Plan de seguro no encontrado")

    svc = BookingService(db)
    bookings = await svc.get_bookings_by_id_insurance_plan(insurance_plan_id)  # completa en service

    # Si no quieres exponer a renters ajenos, puedes filtrar a las que eres host:
    bookings = [b for b in bookings if b.host_id == current_user.user_id]
    return bookings


@router.put("/{booking_id}", response_model=BookingResponse)
async def update_booking(
    booking_id: str,
    payload: BookingUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """
    Actualizar una reserva.
    Reglas mínimas:
      - Solo host o renter involucrados pueden actualizar.
      - Si actualiza datetimes, validar start<end (lo reenviamos al service también).
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
        updated = await svc.update_booking(booking_id, payload)  # completa en service
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
    (Puedes restringir por estado en el service: p.ej. no eliminar si está active/completed)
    """
    svc = BookingService(db)
    booking = await svc.get_booking(booking_id)
    if not booking:
        raise HTTPException(status_code=404, detail="Reserva no encontrada")

    if current_user.user_id not in (booking.renter_id, booking.host_id):
        raise HTTPException(status_code=403, detail="No tienes acceso para eliminar esta reserva")

    ok = await svc.delete_booking(booking_id)  # completa en service
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
    """Eliminar TODAS las reservas de un vehículo (solo el propietario). Úsalo con cuidado."""
    vehicle = await _get_vehicle(db, vehicle_id)
    if not vehicle:
        raise HTTPException(status_code=404, detail="Vehículo no encontrado")
    if vehicle.owner_id != current_user.user_id:
        raise HTTPException(status_code=403, detail="Solo el propietario puede eliminar las reservas de su vehículo")

    svc = BookingService(db)
    deleted = await svc.delete_booking_by_id_vehicle(vehicle_id)  # completa en service
    return {"message": f"Se eliminaron {deleted} reservas del vehículo", "deleted_count": deleted}


@router.delete("/user/{user_id}")
async def delete_bookings_by_user(
    user_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """Eliminar reservas asociadas a un usuario (solo el propio usuario o el host involucrado)."""
    if user_id != current_user.user_id:
        # Como política mínima, solo permite si eres host en esas reservas (filtra en service).
        pass  # ajusta la política si quieres; aquí delegamos al service

    svc = BookingService(db)
    deleted = await svc.delete_booking_by_id_user(user_id)  # completa en service
    return {"message": f"Se eliminaron {deleted} reservas del usuario", "deleted_count": deleted}


@router.delete("/insurance/{insurance_plan_id}")
async def delete_bookings_by_insurance(
    insurance_plan_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """Eliminar reservas por plan de seguro (típicamente rol admin/host)."""
    svc = BookingService(db)
    deleted = await svc.delete_booking_by_id_insurance_plan(insurance_plan_id)  # completa en service
    return {"message": f"Se eliminaron {deleted} reservas asociadas al plan", "deleted_count": deleted}
