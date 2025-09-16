from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from app.db.models import PaymentStatus

# Base schemas
class PaymentBase(BaseModel):
    amount: float = Field(..., gt=0, description="Amount to pay per reservation")
    currency: str = Field(default="USD", min_length=3, max_length=3, description="Currency (USD, EUR, etc.)")
    status: str = Field(..., description="Payment status (pending, paid, failed, etc.)")
    provider: Optional[str] = Field(None, max_length=40, description="Payment provider (stripe, adyen, etc.)")
    provider_ref: Optional[str] = Field(None, max_length=120, description="External provider reference ID")
    created_at: Optional[datetime] = Field(default_factory=datetime.utcnow)


class PaymentCreate(PaymentBase):
    booking_id: str
    payer_id: str


class PaymentUpdate(BaseModel):
    amount: Optional[float] = Field(None, gt=0)
    currency: Optional[str] = Field(None, min_length=3, max_length=3)
    status: Optional[PaymentStatus] = None
    provider: Optional[str] = Field(None, max_length=40)
    provider_ref: Optional[str] = Field(None, max_length=120)

class PaymentResponse(PaymentBase):
    payment_id: str
    booking_id: str
    payer_id: str
    created_at: datetime

    class Config:
        from_attributes = True
