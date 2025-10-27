from __future__ import annotations

import uuid
from typing import List, Optional, Dict, Any

from sqlalchemy import select, update, delete, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import InsurancePlan, Booking
from app.schemas.insurance_plan import InsurancePlanCreate, InsurancePlanUpdate


def _uuid() -> str:
    return str(uuid.uuid4())


class InsurancePlanService:
    def __init__(self, db: AsyncSession):
        self.db = db

    # ----------------------------
    # CREATE
    # ----------------------------
    async def create_insurance_plan(self, insurance_plan_data: InsurancePlanCreate) -> InsurancePlan:
        plan = InsurancePlan(
            insurance_plan_id=_uuid(),
            name=insurance_plan_data.name,
            deductible=insurance_plan_data.deductible,
            daily_cost=insurance_plan_data.daily_cost,
            coverage_summary=insurance_plan_data.coverage_summary,
            active=True if insurance_plan_data.active is None else insurance_plan_data.active,
        )
        self.db.add(plan)
        await self.db.commit()
        await self.db.refresh(plan)
        return plan

    # ----------------------------
    # GET
    # ----------------------------
    async def get_insurance_plan(self, insurance_plan_id: str) -> Optional[InsurancePlan]:
        q = select(InsurancePlan).where(InsurancePlan.insurance_plan_id == insurance_plan_id)
        res = await self.db.execute(q)
        return res.scalar_one_or_none()

    async def get_insurance_plans(
        self, *, skip: int = 0, limit: int = 100, active: Optional[bool] = None
    ) -> Dict[str, Any]:
        base = select(InsurancePlan)
        count_q = select(func.count(InsurancePlan.insurance_plan_id))

        if active is not None:
            base = base.where(InsurancePlan.active == active)
            count_q = count_q.where(InsurancePlan.active == active)

        total_res = await self.db.execute(count_q)
        total = total_res.scalar() or 0

        page_q = await self.db.execute(
            base.offset(skip).limit(limit)
        )
        items = list(page_q.scalars().all())

        return {
            "items": items,
            "total": total,
            "skip": skip,
            "limit": limit,
        }

    async def get_insurance_plan_by_id_booking(self, booking_id: str) -> Optional[InsurancePlan]:
        q = (
            select(InsurancePlan)
            .join(Booking, Booking.insurance_plan_id == InsurancePlan.insurance_plan_id)
            .where(Booking.booking_id == booking_id)
        )
        res = await self.db.execute(q)
        return res.scalar_one_or_none()

    async def get_insurance_plans_by_id_booking(self, booking_id: str) -> List[InsurancePlan]:
        # Typically a booking has a single plan; return as list for API symmetry.
        p = await self.get_insurance_plan_by_id_booking(booking_id)
        return [p] if p else []

    # ----------------------------
    # UPDATE
    # ----------------------------
    async def update_insurance_plan(self, insurance_plan_id: str, payload: InsurancePlanUpdate) -> Optional[InsurancePlan]:
        values = {k: v for k, v in payload.dict(exclude_unset=True).items()}
        if not values:
            return await self.get_insurance_plan(insurance_plan_id)

        stmt = (
            update(InsurancePlan)
            .where(InsurancePlan.insurance_plan_id == insurance_plan_id)
            .values(**values)
            .execution_options(synchronize_session="fetch")
        )
        await self.db.execute(stmt)
        await self.db.commit()
        return await self.get_insurance_plan(insurance_plan_id)

    # ----------------------------
    # DELETE
    # ----------------------------
    async def delete_insurance_plan(self, insurance_plan_id: str) -> bool:
        stmt = delete(InsurancePlan).where(InsurancePlan.insurance_plan_id == insurance_plan_id)
        res = await self.db.execute(stmt)
        await self.db.commit()
        return res.rowcount > 0

    async def delete_insurance_plan_by_id_booking(self, booking_id: str) -> int:
        """
        Desasocia el plan de seguro de una reserva (no borra el plan).
        Retorna 1 si se actualizó la reserva, 0 en caso contrario.
        """
        stmt = (
            update(Booking)
            .where(Booking.booking_id == booking_id)
            .values(insurance_plan_id=None)
            .execution_options(synchronize_session="fetch")
        )
        res = await self.db.execute(stmt)
        await self.db.commit()
        return res.rowcount or 0
