from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime


class BookingReminderResponse(BaseModel):
    booking_id: str
    renter_id: str
    vehicle_id: str
    start_ts: datetime
    minutes_until_start: int
    should_notify: bool
    time_remaining_formatted: str
    
    class Config:
        from_attributes = True


class BookingReminderListResponse(BaseModel):
    bookings: List[BookingReminderResponse]
    threshold_hours: int
    total_count: int


class BookingReminderStatusResponse(BaseModel):
    found: bool
    booking_id: Optional[str] = None
    renter_id: Optional[str] = None
    vehicle_id: Optional[str] = None
    start_ts: Optional[str] = None
    current_time: Optional[str] = None
    hours_until_start: Optional[float] = None
    minutes_until_start: Optional[int] = None
    reached_threshold: Optional[bool] = None
    should_notify: Optional[bool] = None
    threshold_hours: Optional[int] = None
    time_remaining_formatted: Optional[str] = None
    status: Optional[str] = None
    message: str


class UpcomingBookingResponse(BaseModel):
    booking_id: str
    vehicle_id: str
    start_ts: str
    end_ts: str
    hours_until_start: float
    reached_threshold: bool
    time_remaining_formatted: str


class UpcomingBookingsListResponse(BaseModel):
    user_id: str
    bookings: List[UpcomingBookingResponse]
    hours_ahead: int
    total_count: int