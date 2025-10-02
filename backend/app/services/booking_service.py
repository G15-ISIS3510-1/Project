from __future__ import annotations

import uuid
from typing import List, Optional
from datetime import datetime

from sqlalchemy import and_, or_, select, update, delete, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import (
    Booking,
    BookingStatus,
    VehicleAvailability,
)

from app.schemas.booking import BookingCreate, BookingUpdate


def _uuid() -> str:
    return str(uuid.uuid4())


def _overlap_clause(start_ts: datetime, end_ts: datetime):
    """
    Two ranges [A,B] and [C,D] overlap iff A < D and C < B
    (using strict inequality avoids zero-length overlaps).
    """
    return and_(
        Booking.start_ts < end_ts,
        start_ts < Booking.end_ts,
    )


class BookingService:
    def __init__(self, db: AsyncSession):
        self.db = db

    # ----------------------------
    # CREATE
    # ----------------------------
    async def create_booking(self, booking_data: BookingCreate) -> Booking:
        """
        Rules enforced here:
          - No time overlap with existing non-cancelled bookings for the same vehicle.
          - There exists at least one availability slot that fully covers [start_ts, end_ts]
            with type == 'available'.
        """
        # 1) Overlap check (exclude CANCELLED)
        q_overlap = (
            select(func.count(Booking.booking_id))
            .where(
                and_(
                    Booking.vehicle_id == booking_data.vehicle_id,
                    Booking.status != BookingStatus.cancelled,
                    _overlap_clause(booking_data.start_ts, booking_data.end_ts),
                )
            )
        )
        res_overlap = await self.db.execute(q_overlap)
        if res_overlap.scalar_one() > 0:
            raise ValueError("El vehículo ya tiene reservas que se solapan en el rango solicitado.")

        # 2) Availability coverage check (single slot that covers entirely)
        q_av = (
            select(func.count(VehicleAvailability.availability_id))
            .where(
                and_(
                    VehicleAvailability.vehicle_id == booking_data.vehicle_id,
                    VehicleAvailability.type == "available",
                    VehicleAvailability.start_ts <= booking_data.start_ts,
                    VehicleAvailability.end_ts >= booking_data.end_ts,
                )
            )
        )
        res_av = await self.db.execute(q_av)
        if res_av.scalar_one() == 0:
            raise ValueError("No hay disponibilidad registrada para cubrir todo el rango solicitado.")

        # 3) Create booking
        new_booking = Booking(
            booking_id=_uuid(),
            vehicle_id=booking_data.vehicle_id,
            renter_id=booking_data.renter_id,
            host_id=booking_data.host_id,
            insurance_plan_id=booking_data.insurance_plan_id,
            start_ts=booking_data.start_ts,
            end_ts=booking_data.end_ts,
            status=booking_data.status or BookingStatus.pending,
            # snapshots
            daily_price_snapshot=booking_data.daily_price_snapshot,
            insurance_daily_cost_snapshot=booking_data.insurance_daily_cost_snapshot,
            subtotal=booking_data.subtotal,
            fees=booking_data.fees or 0,
            taxes=booking_data.taxes or 0,
            total=booking_data.total,
            currency=booking_data.currency or "USD",
            # vehicle state
            odo_start=booking_data.odo_start,
            odo_end=booking_data.odo_end,
            fuel_start=booking_data.fuel_start,
            fuel_end=booking_data.fuel_end,
        )

        self.db.add(new_booking)
        await self.db.commit()
        await self.db.refresh(new_booking)
        return new_booking

    # ----------------------------
    # GET (single)
    # ----------------------------
    async def get_booking(self, booking_id: str) -> Optional[Booking]:
        q = select(Booking).where(Booking.booking_id == booking_id)
        res = await self.db.execute(q)
        return res.scalar_one_or_none()

    # ----------------------------
    # GET (collections)
    # ----------------------------
    async def get_bookings(
        self,
        *,
        for_user_id: Optional[str] = None,
        status_filter: Optional[BookingStatus] = None,
        skip: int = 0,
        limit: int = 100,
    ) -> List[Booking]:
        q = select(Booking)

        if for_user_id:
            q = q.where(
                or_(Booking.renter_id == for_user_id, Booking.host_id == for_user_id)
            )
        if status_filter:
            q = q.where(Booking.status == status_filter)

        q = q.order_by(Booking.created_at.desc()).offset(skip).limit(limit)
        res = await self.db.execute(q)
        return list(res.scalars().all())

    async def get_bookings_by_id_vehicle(
        self, vehicle_id: str, *, skip: int = 0, limit: int = 100
    ) -> List[Booking]:
        q = (
            select(Booking)
            .where(Booking.vehicle_id == vehicle_id)
            .order_by(Booking.created_at.desc())
            .offset(skip)
            .limit(limit)
        )
        res = await self.db.execute(q)
        return list(res.scalars().all())

    async def get_bookings_by_id_user(
        self, user_id: str, *, skip: int = 0, limit: int = 100
    ) -> List[Booking]:
        q = (
            select(Booking)
            .where(or_(Booking.renter_id == user_id, Booking.host_id == user_id))
            .order_by(Booking.created_at.desc())
            .offset(skip)
            .limit(limit)
        )
        res = await self.db.execute(q)
        return list(res.scalars().all())

    async def get_bookings_by_id_insurance_plan(
        self, insurance_plan_id: str, *, skip: int = 0, limit: int = 100
    ) -> List[Booking]:
        q = (
            select(Booking)
            .where(Booking.insurance_plan_id == insurance_plan_id)
            .order_by(Booking.created_at.desc())
            .offset(skip)
            .limit(limit)
        )
        res = await self.db.execute(q)
        return list(res.scalars().all())

    # ----------------------------
    # UPDATE
    # ----------------------------
    async def update_booking(self, booking_id: str, payload: BookingUpdate) -> Booking:
        current = await self.get_booking(booking_id)
        if not current:
            raise ValueError("Reserva no encontrada")

        # If changing the time window, validate overlap & availability again
        new_start = payload.start_ts or current.start_ts
        new_end = payload.end_ts or current.end_ts
        if new_end <= new_start:
            raise ValueError("end_ts debe ser mayor a start_ts")

        # overlap check (excluding itself and CANCELLED)
        q_overlap = (
            select(func.count(Booking.booking_id))
            .where(
                and_(
                    Booking.vehicle_id == current.vehicle_id,
                    Booking.booking_id != current.booking_id,
                    Booking.status != BookingStatus.cancelled,
                    _overlap_clause(new_start, new_end),
                )
            )
        )
        res_overlap = await self.db.execute(q_overlap)
        if res_overlap.scalar_one() > 0:
            raise ValueError("Nuevo rango temporal se solapa con otra reserva.")

        # availability check
        q_av = (
            select(func.count(VehicleAvailability.availability_id))
            .where(
                and_(
                    VehicleAvailability.vehicle_id == current.vehicle_id,
                    VehicleAvailability.type == "available",
                    VehicleAvailability.start_ts <= new_start,
                    VehicleAvailability.end_ts >= new_end,
                )
            )
        )
        res_av = await self.db.execute(q_av)
        if res_av.scalar_one() == 0:
            raise ValueError("No hay disponibilidad para cubrir el nuevo rango.")

        # Perform update
        values = {k: v for k, v in payload.dict(exclude_unset=True).items()}
        if values:
            stmt = (
                update(Booking)
                .where(Booking.booking_id == booking_id)
                .values(**values)
                .execution_options(synchronize_session="fetch")
            )
            await self.db.execute(stmt)
            await self.db.commit()

        # Return refreshed entity
        refreshed = await self.get_booking(booking_id)
        return refreshed  # type: ignore[return-value]

    # ----------------------------
    # DELETE
    # ----------------------------
    async def delete_booking(self, booking_id: str) -> bool:
        stmt = delete(Booking).where(Booking.booking_id == booking_id)
        res = await self.db.execute(stmt)
        await self.db.commit()
        return res.rowcount > 0

    async def delete_booking_by_id_vehicle(self, vehicle_id: str) -> int:
        stmt = delete(Booking).where(Booking.vehicle_id == vehicle_id)
        res = await self.db.execute(stmt)
        await self.db.commit()
        return res.rowcount or 0

    async def delete_booking_by_id_user(self, user_id: str) -> int:
        stmt = delete(Booking).where(
            or_(Booking.renter_id == user_id, Booking.host_id == user_id)
        )
        res = await self.db.execute(stmt)
        await self.db.commit()
        return res.rowcount or 0

    async def delete_booking_by_id_insurance_plan(self, insurance_plan_id: str) -> int:
        stmt = delete(Booking).where(Booking.insurance_plan_id == insurance_plan_id)
        res = await self.db.execute(stmt)
        await self.db.commit()
        return res.rowcount or 0
