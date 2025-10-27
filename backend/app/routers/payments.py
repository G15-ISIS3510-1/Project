from __future__ import annotations

from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel

from app.db.base import get_db
from app.db.models import User, Payment
from app.schemas.payment import (
    PaymentCreate,
    PaymentUpdate,
    PaymentResponse,
    PaymentMethodAnalytics,
)
from app.services.payment_service import PaymentService
from app.routers.users import get_current_user_from_token
from sqlalchemy import select, update

from datetime import datetime, timedelta
from sqlalchemy import func

router = APIRouter(prefix="/payments", tags=["payments"])


# ---------- pagination response model ----------

class PaginatedPaymentResponse(BaseModel):
    items: List[PaymentResponse]
    total: int
    skip: int
    limit: int


@router.post("/", response_model=PaymentResponse, status_code=status.HTTP_201_CREATED)
async def create_payment(
    payload: PaymentCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """
    Create a payment. Policy (service level): payer must be the booking's renter.
    Additionally, enforce that the authenticated user is the payer.
    """
    if payload.payer_id != current_user.user_id:
        raise HTTPException(status_code=403, detail="You can only create payments for yourself")

    svc = PaymentService(db)
    try:
        payment = await svc.create_payment(payload)
        return payment
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/", response_model=PaginatedPaymentResponse)
async def list_my_payments(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """
    List payments of the authenticated user (as payer), paginated.
    Returns { items, total, skip, limit }.
    """
    svc = PaymentService(db)
    data = await svc.get_payments_by_id_user(
        current_user.user_id,
        skip=skip,
        limit=limit
    )

    serialized = [PaymentResponse.from_orm(p) for p in data["items"]]

    return {
        "items": serialized,
        "total": data["total"],
        "skip": data["skip"],
        "limit": data["limit"],
    }


@router.get("/analytics/adoption", response_model=List[PaymentMethodAnalytics])
async def get_payment_method_adoption(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    three_months_ago = datetime.utcnow() - timedelta(days=90)

    # agregamos total para calcular porcentaje
    total_q = await db.execute(
        select(func.count(Payment.payment_id)).where(Payment.created_at >= three_months_ago)
    )
    total = total_q.scalar() or 0

    if total == 0:
        return []

    q = await db.execute(
        select(
            Payment.payment_method,
            func.count(Payment.payment_id).label("count")
        )
        .where(Payment.created_at >= three_months_ago)
        .group_by(Payment.payment_method)
        .order_by(func.count(Payment.payment_id).asc())
    )
    rows = q.all()

    return [
        PaymentMethodAnalytics(
            name=row.payment_method or "unknown",
            count=row.count,
            percentage=round((row.count / total) * 100, 2)
        )
        for row in rows
    ]


@router.get("/{payment_id}", response_model=PaymentResponse)
async def get_payment(
    payment_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    svc = PaymentService(db)
    payment = await svc.get_payment(payment_id)
    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")
    if payment.payer_id != current_user.user_id:
        # If you want hosts to see payments related to their bookings, loosen this.
        raise HTTPException(status_code=403, detail="Not allowed to view this payment")
    return payment


@router.get("/by-booking/{booking_id}", response_model=PaginatedPaymentResponse)
async def get_payments_by_booking(
    booking_id: str,
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """
    Payments for a booking, paginated.
    Minimal policy: only return payments where you are the payer.
    """
    svc = PaymentService(db)
    data = await svc.get_payments_by_id_booking(
        booking_id,
        skip=skip,
        limit=limit
    )

    # filter down to the caller's own payments
    visible_items = [
        p for p in data["items"]
        if p.payer_id == current_user.user_id
    ]

    serialized = [PaymentResponse.from_orm(p) for p in visible_items]

    # we expose the filtered count as total here
    return {
        "items": serialized,
        "total": len(visible_items),
        "skip": skip,
        "limit": limit,
    }


@router.put("/{payment_id}", response_model=PaymentResponse)
async def update_payment(
    payment_id: str,
    payload: PaymentUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    svc = PaymentService(db)
    entity = await svc.get_payment(payment_id)
    if not entity:
        raise HTTPException(status_code=404, detail="Payment not found")
    if entity.payer_id != current_user.user_id:
        raise HTTPException(status_code=403, detail="You can only update your own payments")

    try:
        updated = await svc.update_payment(payment_id, payload)
        return updated  # type: ignore[return-value]
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.delete("/{payment_id}")
async def delete_payment(
    payment_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    svc = PaymentService(db)
    entity = await svc.get_payment(payment_id)
    if not entity:
        raise HTTPException(status_code=404, detail="Payment not found")
    if entity.payer_id != current_user.user_id:
        raise HTTPException(status_code=403, detail="You can only delete your own payments")

    ok = await svc.delete_payment(payment_id)
    if not ok:
        raise HTTPException(status_code=500, detail="Could not delete payment")
    return {"message": "Payment deleted successfully"}


# Optional bulk deletions (guard these if needed)

@router.delete("/by-user/{user_id}")
async def delete_payments_by_user(
    user_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    if user_id != current_user.user_id:
        raise HTTPException(status_code=403, detail="You can only delete your own payments")
    svc = PaymentService(db)
    count = await svc.delete_payment_by_id_user(user_id)
    return {"message": f"Deleted {count} payments", "deleted_count": count}


@router.delete("/by-booking/{booking_id}")
async def delete_payments_by_booking(
    booking_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    # Minimal policy: only delete payments if you are the payer of those payments
    svc = PaymentService(db)
    data = await svc.get_payments_by_id_booking(booking_id, skip=0, limit=10_000)
    my_payments = [p for p in data["items"] if p.payer_id == current_user.user_id]
    if not my_payments:
        raise HTTPException(status_code=403, detail="You can only delete your own payments")

    count = await svc.delete_payment_by_id_booking(booking_id)
    return {
        "message": f"Deleted {count} payments for booking",
        "deleted_count": count
    }
