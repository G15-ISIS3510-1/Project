from pydantic import BaseModel, Field
from typing import Any, Dict, List, Optional
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


class FeesTaxesAverageResponse(BaseModel):
    average: float = Field(..., description="Average of (fees + taxes) per booking")
    sample_size: int = Field(..., description="Number of bookings considered")
class FeatureUsageLogRequest(BaseModel):
    feature_name: str = Field(..., min_length=1, max_length=100)
    duration_seconds: Optional[float] = Field(None, ge=0)
    duration_ms: Optional[int] = Field(None, ge=0)
    origin_route: Optional[str] = Field(None, max_length=120)
    destination_route: Optional[str] = Field(None, max_length=120)
    metadata: Optional[Dict[str, Any]] = None


class FeatureUsageLogResponse(BaseModel):
    id: int
    feature_name: str
    user_id: str
    duration_seconds: Optional[float] = None
    timestamp: datetime
    metadata: Optional[Dict[str, Any]] = None
