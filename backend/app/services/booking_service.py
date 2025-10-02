from sqlalchemy.ext.asyncio import AsyncSession
from app.schemas.booking import BookingCreate, BookingUpdate
from app.db.models import Booking, User, Vehicle, InsurancePlan
from sqlalchemy import select
import uuid
from typing import Optional, List
from datetime import datetime


class BookingService:
    def __init__(self, db: AsyncSession):
        self.db = db

    # CREATE
    async def create_booking(self, booking_data: BookingCreate) -> Booking:
        """Crear una nueva reserva con validaciones de negocio"""
        # Verificar que el vehículo existe
        vehicle = await self.get_vehicle_by_id(booking_data.vehicle_id)
        if not vehicle:
            raise ValueError("El vehículo no existe")
        
        # Verificar que el renter existe
        renter = await self.get_user_by_id(booking_data.renter_id)
        if not renter:
            raise ValueError("El usuario renter no existe")
        
        # Verificar que el host existe
        host = await self.get_user_by_id(booking_data.host_id)
        if not host:
            raise ValueError("El usuario host no existe")
        
        # Verificar que el insurance plan existe (si se proporciona)
        if booking_data.insurance_plan_id:
            insurance_plan = await self.get_insurance_plan_by_id(booking_data.insurance_plan_id)
            if not insurance_plan:
                raise ValueError("El plan de seguro no existe")
            if not insurance_plan.active:
                raise ValueError("El plan de seguro no está activo")

        # Verificar que las fechas son válidas
        if booking_data.start_ts >= booking_data.end_ts:
            raise ValueError("La fecha de inicio debe ser anterior a la fecha de fin")
        
        if booking_data.start_ts <= datetime.utcnow():
            raise ValueError("La fecha de inicio debe ser en el futuro")

        # Verificar disponibilidad del vehículo
        conflicting_bookings = await self.get_conflicting_bookings(
            booking_data.vehicle_id, 
            booking_data.start_ts, 
            booking_data.end_ts
        )
        if conflicting_bookings:
            raise ValueError("El vehículo no está disponible en las fechas seleccionadas")

        booking = Booking(
            booking_id=str(uuid.uuid4()),
            vehicle_id=booking_data.vehicle_id,
            renter_id=booking_data.renter_id,
            host_id=booking_data.host_id,
            insurance_plan_id=booking_data.insurance_plan_id,
            start_ts=booking_data.start_ts,
            end_ts=booking_data.end_ts,
            daily_price_snapshot=booking_data.daily_price_snapshot,
            insurance_daily_cost_snapshot=booking_data.insurance_daily_cost_snapshot,
            subtotal=booking_data.subtotal,
            fees=booking_data.fees,
            taxes=booking_data.taxes,
            total=booking_data.total,
            currency=booking_data.currency,
            odo_start=booking_data.odo_start,
            odo_end=booking_data.odo_end,
            fuel_start=booking_data.fuel_start,
            fuel_end=booking_data.fuel_end,
            status=booking_data.status,
        )
        self.db.add(booking)
        await self.db.commit()
        await self.db.refresh(booking)
        return booking

    # GET
    async def get_booking(self, booking_id: str) -> Optional[Booking]:
        """Obtener reserva por ID"""
        res = await self.db.execute(select(Booking).where(Booking.booking_id == booking_id))
        return res.scalar_one_or_none()

    async def get_bookings(self, skip: int = 0, limit: int = 100) -> List[Booking]:
        """Obtener todas las reservas con paginación"""
        res = await self.db.execute(select(Booking).offset(skip).limit(limit))
        return res.scalars().all()

    async def get_booking_by_id_vehicle(self, vehicle_id: str) -> Optional[Booking]:
        """Obtener primera reserva de un vehículo específico"""
        res = await self.db.execute(
            select(Booking).where(Booking.vehicle_id == vehicle_id).limit(1)
        )
        return res.scalar_one_or_none()

    async def get_bookings_by_id_vehicle(self, vehicle_id: str, skip: int = 0, limit: int = 100) -> List[Booking]:
        """Obtener todas las reservas de un vehículo específico"""
        res = await self.db.execute(
            select(Booking)
            .where(Booking.vehicle_id == vehicle_id)
            .offset(skip)
            .limit(limit)
        )
        return res.scalars().all()

    async def get_booking_by_id_user(self, user_id: str, as_renter: bool = True) -> Optional[Booking]:
        """Obtener primera reserva de un usuario (como renter o host)"""
        if as_renter:
            res = await self.db.execute(
                select(Booking).where(Booking.renter_id == user_id).limit(1)
            )
        else:
            res = await self.db.execute(
                select(Booking).where(Booking.host_id == user_id).limit(1)
            )
        return res.scalar_one_or_none()

    async def get_bookings_by_id_user(self, user_id: str, as_renter: bool = True, skip: int = 0, limit: int = 100) -> List[Booking]:
        """Obtener todas las reservas de un usuario (como renter o host)"""
        if as_renter:
            res = await self.db.execute(
                select(Booking)
                .where(Booking.renter_id == user_id)
                .offset(skip)
                .limit(limit)
            )
        else:
            res = await self.db.execute(
                select(Booking)
                .where(Booking.host_id == user_id)
                .offset(skip)
                .limit(limit)
            )
        return res.scalars().all()

    async def get_booking_by_id_insurance_plan(self, insurance_plan_id: str) -> Optional[Booking]:
        """Obtener primera reserva con un plan de seguro específico"""
        res = await self.db.execute(
            select(Booking).where(Booking.insurance_plan_id == insurance_plan_id).limit(1)
        )
        return res.scalar_one_or_none()

    async def get_bookings_by_id_insurance_plan(self, insurance_plan_id: str, skip: int = 0, limit: int = 100) -> List[Booking]:
        """Obtener todas las reservas con un plan de seguro específico"""
        res = await self.db.execute(
            select(Booking)
            .where(Booking.insurance_plan_id == insurance_plan_id)
            .offset(skip)
            .limit(limit)
        )
        return res.scalars().all()

    async def get_conflicting_bookings(self, vehicle_id: str, start_ts: datetime, end_ts: datetime) -> List[Booking]:
        """Verificar si hay reservas que conflicten con las fechas dadas"""
        res = await self.db.execute(
            select(Booking)
            .where(
                Booking.vehicle_id == vehicle_id,
                Booking.status.in_(["pending", "confirmed", "active"]),
                # Overlap condition: start < other_end AND end > other_start
                Booking.start_ts < end_ts,
                Booking.end_ts > start_ts
            )
        )
        return res.scalars().all()

    # UPDATE
    async def update_booking(self, booking_id: str, booking_update: BookingUpdate) -> Optional[Booking]:
        """Actualizar reserva con validaciones de negocio"""
        booking = await self.get_booking(booking_id)
        if not booking:
            return None

        update_data = booking_update.model_dump(exclude_unset=True)

        # Validaciones de fechas si se actualizan
        if "start_ts" in update_data or "end_ts" in update_data:
            new_start = update_data.get("start_ts", booking.start_ts)
            new_end = update_data.get("end_ts", booking.end_ts)
            
            if new_start >= new_end:
                raise ValueError("La fecha de inicio debe ser anterior a la fecha de fin")
            
            # Verificar conflictos solo si cambian las fechas
            if new_start != booking.start_ts or new_end != booking.end_ts:
                conflicting_bookings = await self.get_conflicting_bookings(
                    booking.vehicle_id, new_start, new_end
                )
                # Filtrar la reserva actual de los conflictos
                conflicting_bookings = [b for b in conflicting_bookings if b.booking_id != booking_id]
                if conflicting_bookings:
                    raise ValueError("Las nuevas fechas conflictan con otras reservas")

        # Normalizar currency si se proporciona
        if "currency" in update_data and update_data["currency"]:
            update_data["currency"] = update_data["currency"].upper()

        for field, value in update_data.items():
            setattr(booking, field, value)

        await self.db.commit()
        await self.db.refresh(booking)
        return booking

    async def update_booking_by_id_vehicle(self, vehicle_id: str, booking_update: BookingUpdate) -> Optional[Booking]:
        """Actualizar primera reserva de un vehículo"""
        booking = await self.get_booking_by_id_vehicle(vehicle_id)
        if not booking:
            return None
        return await self.update_booking(booking.booking_id, booking_update)

    async def update_booking_by_id_user(self, user_id: str, booking_update: BookingUpdate, as_renter: bool = True) -> Optional[Booking]:
        """Actualizar primera reserva de un usuario"""
        booking = await self.get_booking_by_id_user(user_id, as_renter)
        if not booking:
            return None
        return await self.update_booking(booking.booking_id, booking_update)

    async def update_booking_by_id_insurance_plan(self, insurance_plan_id: str, booking_update: BookingUpdate) -> Optional[Booking]:
        """Actualizar primera reserva con un plan de seguro específico"""
        booking = await self.get_booking_by_id_insurance_plan(insurance_plan_id)
        if not booking:
            return None
        return await self.update_booking(booking.booking_id, booking_update)

    # DELETE
    async def delete_booking(self, booking_id: str) -> bool:
        """Eliminar reserva (cancelar)"""
        booking = await self.get_booking(booking_id)
        if not booking:
            return False
        
        # Verificar si se puede cancelar según el estado
        if booking.status in ["completed"]:
            raise ValueError("No se puede eliminar una reserva completada")
        
        await self.db.delete(booking)
        await self.db.commit()
        return True

    async def delete_booking_by_id_vehicle(self, vehicle_id: str) -> bool:
        """Eliminar todas las reservas de un vehículo"""
        bookings = await self.get_bookings_by_id_vehicle(vehicle_id, skip=0, limit=10_000)
        if not bookings:
            return False
        
        for booking in bookings:
            if booking.status not in ["completed"]:
                await self.db.delete(booking)
        
        await self.db.commit()
        return True

    async def delete_booking_by_id_user(self, user_id: str, as_renter: bool = True) -> bool:
        """Eliminar todas las reservas de un usuario"""
        bookings = await self.get_bookings_by_id_user(user_id, as_renter, skip=0, limit=10_000)
        if not bookings:
            return False
        
        for booking in bookings:
            if booking.status not in ["completed"]:
                await self.db.delete(booking)
        
        await self.db.commit()
        return True

    async def delete_booking_by_id_insurance_plan(self, insurance_plan_id: str) -> bool:
        """Eliminar todas las reservas con un plan de seguro específico"""
        bookings = await self.get_bookings_by_id_insurance_plan(insurance_plan_id, skip=0, limit=10_000)
        if not bookings:
            return False
        
        for booking in bookings:
            if booking.status not in ["completed"]:
                await self.db.delete(booking)
        
        await self.db.commit()
        return True

    # HELPER METHODS
    async def get_user_by_id(self, user_id: str) -> Optional[User]:
        """Verificar si existe un usuario"""
        result = await self.db.execute(
            select(User).where(User.user_id == user_id)
        )
        return result.scalar_one_or_none()

    async def get_vehicle_by_id(self, vehicle_id: str) -> Optional[Vehicle]:
        """Verificar si existe un vehículo"""
        result = await self.db.execute(
            select(Vehicle).where(Vehicle.vehicle_id == vehicle_id)
        )
        return result.scalar_one_or_none()

    async def get_insurance_plan_by_id(self, insurance_plan_id: str) -> Optional[InsurancePlan]:
        """Verificar si existe un plan de seguro"""
        result = await self.db.execute(
            select(InsurancePlan).where(InsurancePlan.insurance_plan_id == insurance_plan_id)
        )
        return result.scalar_one_or_none()



