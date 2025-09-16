from sqlalchemy.ext.asyncio import AsyncSession
from app.schemas.payment import PaymentCreate, PaymentUpdate
from app.db.models import Payment, Booking, User
from sqlalchemy import select
import uuid
from typing import Optional, List


class PaymentService:
    def _init_(self, db: AsyncSession ):
        self.db =db

    # CREATE
    async def create_payment(self, payment_data: PaymentCreate) -> Payment:

        booking = await self.get_booking_by_id(payment_data.booking_id)
        if not booking:
            raise ValueError("The booking does not exist")
        
        payer = await self.get_user_by_id(payment_data.payer_id)
        if not payer:
            raise ValueError("The payer does not exist")

        payment = Payment(
            payment_id=str(uuid.uuid4()),
            booking_id=payment_data.booking_id,
            payer_id=payment_data.payer_id,
            amount=payment_data.amount,
            currency=payment_data.currency,
            status=payment_data.status,
            provider=payment_data.provider,
            provider_ref=payment_data.provider_ref,
        )
        self.db.add(payment)
        await self.db.commit()
        await self.db.refresh(payment)
        return payment

    # GET

    async def get_payment(self, payment_id: str) -> Optional[Payment]:
        res = await self.db.execute(select(Payment).where(Payment.payment_id == payment_id))
        return res.scalar_one_or_none()
    
    async def get_payments(self, skip: int = 0, limit: int = 100) -> List[Payment]:
        res = await self.db.execute(select(Payment).offset(skip).limit(limit))
        return res.scalars().all()

    async def get_payment_by_id_user(self, payer_id: str) -> Optional[Payment]:
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
        return res.scalars().all()

    async def get_payment_by_id_booking(self, booking_id: str) -> Optional[Payment]:
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
        return res.scalars().all()
    
    # UPDATE
    async def update_payment(self, payment_id: str, payment_update: PaymentUpdate) -> Optional[Payment]:
        payment = await self.get_payment(payment_id)
        if not payment:
            return None

        update_data = payment_update.model_dump(exclude_unset=True)

        # Reglas simples de negocio: si se pasa currency, normalizar a upper
        if "currency" in update_data and update_data["currency"]:
            update_data["currency"] = update_data["currency"].upper()

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
    
    # DELETE

    async def delete_payment(self, payment_id: str) -> bool:
        payment = await self.get_payment(payment_id)
        if not payment:
            return False
        await self.db.delete(payment)
        await self.db.commit()
        return True

    async def delete_payment_by_id_user(self, payer_id: str) -> bool:
        payments = await self.get_payments_by_id_user(payer_id, skip=0, limit=10_000)
        if not payments:
            return False
        for p in payments:
            await self.db.delete(p)
        await self.db.commit()
        return True

    async def delete_payment_by_id_booking(self, booking_id: str) -> bool:
        payments = await self.get_payments_by_id_booking(booking_id, skip=0, limit=10_000)
        
        if not payments:
            return False
        for p in payments:
            await self.db.delete(p)
        await self.db.commit()

        return True


    # Check if booking exists
    async def get_booking_by_id(self, booking_id: str):
        result = await self.db.execute(
            select(Booking).where(Booking.booking_id == booking_id)
        )
        return result.scalar_one_or_none()
    
    # Check if user exists
    async def get_user_by_id(self, user_id: str):

        result = await self.db.execute(
            select(User).where(User.user_id == user_id)
        )
        return result.scalar_one_or_none()