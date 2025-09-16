from pydantic import BaseModel, Field, field_validator
from typing import Optional
from datetime import datetime
from enum import Enum
from app.db.models import BookingStatus

class BookingBase(BaseModel):
    # Reservation window
    start_ts: datetime = Field(..., description="Reservation start timestamp")
    end_ts: datetime = Field(..., description="Reservation end timestamp")

    # Economic snapshots
    daily_price_snapshot: float = Field(..., gt=0, description="Daily price of the vehicle at the time of booking")
    insurance_daily_cost_snapshot: Optional[float] = Field(None, ge=0, description="Daily insurance cost at the time of booking")
    subtotal: float = Field(..., ge=0, description="Subtotal amount before fees and taxes")
    fees: Optional[float] = Field(0, ge=0, description="Additional booking fees")
    taxes: Optional[float] = Field(0, ge=0, description="Applied taxes")
    total: float = Field(..., ge=0, description="Final total amount to be paid")
    currency: str = Field(default="USD", min_length=3, max_length=3, description="Currency code in ISO format (USD, EUR, etc.)")

    # Vehicle status
    odo_start: Optional[int] = Field(None, ge=0, description="Vehicle odometer reading at the start of the booking")
    odo_end: Optional[int] = Field(None, ge=0, description="Vehicle odometer reading at the end of the booking")
    fuel_start: Optional[int] = Field(None, ge=0, le=100, description="Fuel level percentage at the start of the booking")
    fuel_end: Optional[int] = Field(None, ge=0, le=100, description="Fuel level percentage at the end of the booking")

    # Booking status
    status: BookingStatus = Field(default=BookingStatus.pending, description="Current booking status")


class BookingCreate(BookingBase):
    vehicle_id: str
    renter_id: str
    host_id: str
    insurance_plan_id: Optional[str] = None


class BookingUpdate(BaseModel):
    start_ts: Optional[datetime] = Field(None, description="Updated reservation start timestamp")
    end_ts: Optional[datetime] = Field(None, description="Updated reservation end timestamp")
    status: Optional[BookingStatus] = Field(None, description="Updated booking status")

    daily_price_snapshot: Optional[float] = Field(None, gt=0, description="Updated daily price snapshot")
    insurance_daily_cost_snapshot: Optional[float] = Field(None, ge=0, description="Updated insurance daily cost snapshot")
    subtotal: Optional[float] = Field(None, ge=0, description="Updated subtotal amount before fees and taxes")
    fees: Optional[float] = Field(None, ge=0, description="Updated booking fees")
    taxes: Optional[float] = Field(None, ge=0, description="Updated booking taxes")
    total: Optional[float] = Field(None, ge=0, description="Updated total amount")
    currency: Optional[str] = Field(None, min_length=3, max_length=3, description="Updated currency code in ISO format (USD, EUR, etc.)")

    odo_start: Optional[int] = Field(None, ge=0, description="Updated odometer reading at the start of the booking")
    odo_end: Optional[int] = Field(None, ge=0, description="Updated odometer reading at the end of the booking")
    fuel_start: Optional[int] = Field(None, ge=0, le=100, description="Updated fuel level percentage at the start")
    fuel_end: Optional[int] = Field(None, ge=0, le=100, description="Updated fuel level percentage at the end")


class BookingResponse(BookingBase):
    booking_id: str
    vehicle_id: str
    renter_id: str
    host_id: str
    insurance_plan_id: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True
