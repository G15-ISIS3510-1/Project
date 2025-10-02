
from sqlalchemy.ext.asyncio import AsyncSession
from app.schemas.insurance_plan import InsurancePlanCreate, InsurancePlanUpdate
from app.db.models import InsurancePlan, Booking
from sqlalchemy import select
import uuid
from typing import Optional, List


class InsurancePlanService:
    def __init__(self, db: AsyncSession):
        self.db = db

    # CREATE
    async def create_insurance_plan(self, insurance_plan_data: InsurancePlanCreate) -> InsurancePlan:
        """Crear un nuevo plan de seguro"""
        # Verificar si ya existe un plan con el mismo nombre
        existing_plan = await self.get_insurance_plan_by_name(insurance_plan_data.name)
        if existing_plan:
            raise ValueError("Ya existe un plan de seguro con ese nombre")

        insurance_plan = InsurancePlan(
            insurance_plan_id=str(uuid.uuid4()),
            name=insurance_plan_data.name,
            deductible=insurance_plan_data.deductible,
            daily_cost=insurance_plan_data.daily_cost,
            coverage_summary=insurance_plan_data.coverage_summary,
            active=insurance_plan_data.active,
        )
        self.db.add(insurance_plan)
        await self.db.commit()
        await self.db.refresh(insurance_plan)
        return insurance_plan

    # GET
    async def get_insurance_plan(self, insurance_plan_id: str) -> Optional[InsurancePlan]:
        """Obtener plan de seguro por ID"""
        res = await self.db.execute(select(InsurancePlan).where(InsurancePlan.insurance_plan_id == insurance_plan_id))
        return res.scalar_one_or_none()

    async def get_insurance_plans(self, skip: int = 0, limit: int = 100) -> List[InsurancePlan]:
        """Obtener todos los planes de seguro con paginación"""
        res = await self.db.execute(select(InsurancePlan).offset(skip).limit(limit))
        return res.scalars().all()

    async def get_insurance_plan_by_name(self, name: str) -> Optional[InsurancePlan]:
        """Obtener plan de seguro por nombre"""
        res = await self.db.execute(select(InsurancePlan).where(InsurancePlan.name == name))
        return res.scalar_one_or_none()

    async def get_active_insurance_plans(self, skip: int = 0, limit: int = 100) -> List[InsurancePlan]:
        """Obtener solo los planes de seguro activos"""
        res = await self.db.execute(
            select(InsurancePlan)
            .where(InsurancePlan.active == True)
            .offset(skip)
            .limit(limit)
        )
        return res.scalars().all()

    async def get_insurance_plan_by_id_booking(self, booking_id: str) -> Optional[InsurancePlan]:
        """Obtener plan de seguro asociado a una reserva específica"""
        booking = await self.get_booking_by_id(booking_id)
        if not booking or not booking.insurance_plan_id:
            return None
        return await self.get_insurance_plan(booking.insurance_plan_id)

    # UPDATE
    async def update_insurance_plan(self, insurance_plan_id: str, insurance_plan_update: InsurancePlanUpdate) -> Optional[InsurancePlan]:
        """Actualizar plan de seguro"""
        insurance_plan = await self.get_insurance_plan(insurance_plan_id)
        if not insurance_plan:
            return None

        update_data = insurance_plan_update.model_dump(exclude_unset=True)

        # Validación de negocio: si se cambia el nombre, verificar que no exista otro plan con ese nombre
        if "name" in update_data and update_data["name"]:
            existing_plan = await self.get_insurance_plan_by_name(update_data["name"])
            if existing_plan and existing_plan.insurance_plan_id != insurance_plan_id:
                raise ValueError("Ya existe otro plan de seguro con ese nombre")

        for field, value in update_data.items():
            setattr(insurance_plan, field, value)

        await self.db.commit()
        await self.db.refresh(insurance_plan)
        return insurance_plan

    # DELETE
    async def delete_insurance_plan(self, insurance_plan_id: str) -> bool:
        """Eliminar plan de seguro (soft delete - marcar como inactivo)"""
        insurance_plan = await self.get_insurance_plan(insurance_plan_id)
        if not insurance_plan:
            return False
        
        # Verificar si hay reservas activas que usen este plan
        active_bookings = await self.get_active_bookings_with_plan(insurance_plan_id)
        if active_bookings:
            # Solo desactivar en lugar de eliminar si hay reservas activas
            insurance_plan.active = False
            await self.db.commit()
            return True
        
        # Si no hay reservas activas, se puede eliminar completamente
        await self.db.delete(insurance_plan)
        await self.db.commit()
        return True

    # HELPER METHODS
    async def get_booking_by_id(self, booking_id: str) -> Optional[Booking]:
        """Verificar si existe una reserva"""
        result = await self.db.execute(
            select(Booking).where(Booking.booking_id == booking_id)
        )
        return result.scalar_one_or_none()

    async def get_active_bookings_with_plan(self, insurance_plan_id: str) -> List[Booking]:
        """Obtener reservas activas que usen un plan de seguro específico"""
        result = await self.db.execute(
            select(Booking)
            .where(
                Booking.insurance_plan_id == insurance_plan_id,
                Booking.status.in_(["pending", "confirmed", "active"])
            )
        )
        return result.scalars().all()

