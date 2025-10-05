from __future__ import annotations

import uuid
from typing import Optional, List

from sqlalchemy import select, update, delete
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import Payment, Booking, User, PaymentStatus
from app.schemas.payment import PaymentCreate, PaymentUpdate


def _uuid() -> str:
    return str(uuid.uuid4())


class PaymentService:
    def __init__(self, db: AsyncSession):
        self.db = db

    # ------------- helpers (existence checks) -------------
    async def _get_booking_by_id(self, booking_id: str) -> Optional[Booking]:
        res = await self.db.execute(select(Booking).where(Booking.booking_id == booking_id))
        return res.scalar_one_or_none()

    async def _get_user_by_id(self, user_id: str) -> Optional[User]:
        res = await self.db.execute(select(User).where(User.user_id == user_id))
        return res.scalar_one_or_none()

    # -------------------- CREATE --------------------------
    async def create_payment(self, payment_data: PaymentCreate) -> Payment:
        """
        Creates a payment only if:
          - booking exists
          - payer exists
          - (policy) payer == booking.renter_id (adjust if you want host/admin to pay)
        """
        booking = await self._get_booking_by_id(payment_data.booking_id)
        if not booking:
            raise ValueError("The booking does not exist")

        payer = await self._get_user_by_id(payment_data.payer_id)
        if not payer:
            raise ValueError("The payer does not exist")

        # Business policy (simple): only the renter pays
        if booking.renter_id != payment_data.payer_id:
            raise ValueError("Only the renter associated with the booking can be the payer")

        # Normalize / coerce fields
        currency = (payment_data.currency or "USD").upper()

        # Accept both str or PaymentStatus for 'status'
        status_val = payment_data.status
        if isinstance(status_val, str):
            try:
                status_val = PaymentStatus(status_val)
            except Exception:
                raise ValueError("Invalid payment status")

        payment = Payment(
            payment_id=_uuid(),
            booking_id=payment_data.booking_id,
            payer_id=payment_data.payer_id,
            amount=payment_data.amount,
            currency=currency,
            status=status_val,
            provider=payment_data.provider,
            provider_ref=payment_data.provider_ref,
        )
        self.db.add(payment)
        await self.db.commit()
        await self.db.refresh(payment)
        return payment

    # ---------------------- GET ---------------------------
    async def get_payment(self, payment_id: str) -> Optional[Payment]:
        res = await self.db.execute(select(Payment).where(Payment.payment_id == payment_id))
        return res.scalar_one_or_none()

    async def get_payments(self, skip: int = 0, limit: int = 100) -> List[Payment]:
        res = await self.db.execute(select(Payment).offset(skip).limit(limit))
        return list(res.scalars().all())

    async def get_payment_by_id_user(self, payer_id: str) -> Optional[Payment]:
        # first payment of a given user (convenience)
        res = await self.db.execute(
            select(Payment).where(Payment.payer_id == payer_id).limit(1)
        )
        return res.scalar_one_or_none()

    async def get_payments_by_id_user(self, payer_id: str, skip: int = 0, limit: int = 100) -> List[Payment]:
        res = await self.db.execute(
            select(Payment)
            .where(Payment.payer_id == payer_id)
            .offset(skip)
            .limit(limit)
        )
        return list(res.scalars().all())

    async def get_payment_by_id_booking(self, booking_id: str) -> Optional[Payment]:
        # first payment of a given booking (convenience)
        res = await self.db.execute(
            select(Payment).where(Payment.booking_id == booking_id).limit(1)
        )
        return res.scalar_one_or_none()

    async def get_payments_by_id_booking(self, booking_id: str, skip: int = 0, limit: int = 100) -> List[Payment]:
        res = await self.db.execute(
            select(Payment)
            .where(Payment.booking_id == booking_id)
            .offset(skip)
            .limit(limit)
        )
        return list(res.scalars().all())

    # -------------------- UPDATE --------------------------
    async def update_payment(self, payment_id: str, payment_update: PaymentUpdate) -> Optional[Payment]:
        payment = await self.get_payment(payment_id)
        if not payment:
            return None

        update_data = payment_update.model_dump(exclude_unset=True)

        # Normalize / coerce
        if "currency" in update_data and update_data["currency"]:
            update_data["currency"] = update_data["currency"].upper()

        if "status" in update_data and update_data["status"] is not None:
            st = update_data["status"]
            if isinstance(st, str):
                try:
                    update_data["status"] = PaymentStatus(st)
                except Exception:
                    raise ValueError("Invalid payment status")
            # if already PaymentStatus, it's fine

        # Apply partial update
        for field, value in update_data.items():
            setattr(payment, field, value)

        await self.db.commit()
        await self.db.refresh(payment)
        return payment

    async def update_payment_by_id_user(self, payer_id: str, payment_update: PaymentUpdate) -> Optional[Payment]:
        payment = await self.get_payment_by_id_user(payer_id)
        if not payment:
            return None
        return await self.update_payment(payment.payment_id, payment_update)

    async def update_payment_by_id_booking(self, booking_id: str, payment_update: PaymentUpdate) -> Optional[Payment]:
        payment = await self.get_payment_by_id_booking(booking_id)
        if not payment:
            return None
        return await self.update_payment(payment.payment_id, payment_update)

    # -------------------- DELETE --------------------------
    async def delete_payment(self, payment_id: str) -> bool:
        payment = await self.get_payment(payment_id)
        if not payment:
            return False
        await self.db.delete(payment)
        await self.db.commit()
        return True

    async def delete_payment_by_id_user(self, payer_id: str) -> int:
        payments = await self.get_payments_by_id_user(payer_id, skip=0, limit=10_000)
        if not payments:
            return 0
        for p in payments:
            await self.db.delete(p)
        await self.db.commit()
        return len(payments)

    async def delete_payment_by_id_booking(self, booking_id: str) -> int:
        payments = await self.get_payments_by_id_booking(booking_id, skip=0, limit=10_000)
        if not payments:
            return 0
        for p in payments:
            await self.db.delete(p)
        await self.db.commit()
        return len(payments)
