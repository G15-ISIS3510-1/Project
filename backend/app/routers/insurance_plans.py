from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel

from app.db.base import get_db
from app.db.models import User
from app.schemas.insurance_plan import (
    InsurancePlanCreate,
    InsurancePlanUpdate,
    InsurancePlanResponse,
)
from app.services.insurance_plan_service import InsurancePlanService
from app.routers.users import get_current_user_from_token

router = APIRouter(tags=["insurance_plans"])


class PaginatedInsurancePlanResponse(BaseModel):
    items: List[InsurancePlanResponse]
    total: int
    skip: int
    limit: int


@router.post("/", response_model=InsurancePlanResponse, status_code=status.HTTP_201_CREATED)
async def create_plan(
    payload: InsurancePlanCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    svc = InsurancePlanService(db)
    plan = await svc.create_insurance_plan(payload)
    return plan


@router.get("/", response_model=PaginatedInsurancePlanResponse)
async def list_plans(
    skip: int = 0,
    limit: int = 100,
    active: Optional[bool] = Query(None, description="Filtra por activos/inactivos"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    svc = InsurancePlanService(db)
    data = await svc.get_insurance_plans(skip=skip, limit=limit, active=active)

    serialized = [InsurancePlanResponse.from_orm(p) for p in data["items"]]
    return {
        "items": serialized,
        "total": data["total"],
        "skip": data["skip"],
        "limit": data["limit"],
    }


@router.get("/{insurance_plan_id}", response_model=InsurancePlanResponse)
async def get_plan(
    insurance_plan_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    svc = InsurancePlanService(db)
    plan = await svc.get_insurance_plan(insurance_plan_id)
    if not plan:
        raise HTTPException(status_code=404, detail="Plan de seguro no encontrado")
    return plan


@router.put("/{insurance_plan_id}", response_model=InsurancePlanResponse)
async def update_plan(
    insurance_plan_id: str,
    payload: InsurancePlanUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    svc = InsurancePlanService(db)
    updated = await svc.update_insurance_plan(insurance_plan_id, payload)
    if not updated:
        raise HTTPException(status_code=404, detail="Plan de seguro no encontrado")
    return updated


@router.delete("/{insurance_plan_id}")
async def delete_plan(
    insurance_plan_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    svc = InsurancePlanService(db)
    ok = await svc.delete_insurance_plan(insurance_plan_id)
    if not ok:
        raise HTTPException(status_code=404, detail="Plan de seguro no encontrado")
    return {"message": "Plan de seguro eliminado correctamente"}


# Opcional: obtener/desasociar plan por booking

@router.get("/by-booking/{booking_id}", response_model=Optional[InsurancePlanResponse])
async def get_plan_by_booking(
    booking_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    svc = InsurancePlanService(db)
    plan = await svc.get_insurance_plan_by_id_booking(booking_id)
    return plan


@router.delete("/by-booking/{booking_id}")
async def detach_plan_from_booking(
    booking_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    svc = InsurancePlanService(db)
    count = await svc.delete_insurance_plan_by_id_booking(booking_id)
    return {"message": "Plan desasociado de la reserva", "updated_count": count}
# ----------------------------