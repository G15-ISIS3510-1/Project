from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime

# Base schemas
class PricingBase(BaseModel):
    daily_price: float = Field(..., gt=0, description="Precio diario del vehículo")
    min_days: int = Field(..., ge=1, description="Mínimo de días de alquiler")
    max_days: Optional[int] = Field(None, ge=1, description="Máximo de días de alquiler")
    currency: str = Field(default="USD", min_length=3, max_length=3, description="Moneda (USD, EUR, etc.)")

class PricingCreate(PricingBase):
    vehicle_id: str = Field(..., description="ID del vehículo")
    # No incluir pricing_id (se genera automáticamente)
    # No incluir last_updated (se genera automáticamente)

class PricingUpdate(BaseModel):
    daily_price: Optional[float] = Field(None, gt=0, description="Precio diario del vehículo")
    min_days: Optional[int] = Field(None, ge=1, description="Mínimo de días de alquiler")
    max_days: Optional[int] = Field(None, ge=1, description="Máximo de días de alquiler")
    currency: Optional[str] = Field(None, min_length=3, max_length=3, description="Moneda")

class PricingResponse(PricingBase):
    pricing_id: str
    vehicle_id: str
    last_updated: datetime
    
    class Config:
        from_attributes = True

class PricingList(BaseModel):  # Para hacer la paginación
    pricings: List[PricingResponse]
    total: int
    page: int
    limit: int

class SuggestPriceRequest(BaseModel):
    make: Optional[str] = None
    model: Optional[str] = None
    year: Optional[int] = Field(None, ge=1900, le=2035)
    transmission: Optional[str] = None  # AT|MT|CVT|EV
    fuel_type: Optional[str] = None     # gas|diesel|hybrid|ev
    seats: Optional[int] = Field(None, ge=1, le=50)
    mileage: Optional[int] = Field(None, ge=0)
    lat: Optional[float] = Field(None, ge=-90, le=90)
    lng: Optional[float] = Field(None, ge=-180, le=180)

class SuggestPriceResponse(BaseModel):
    suggested_price: float
    reasoning: Optional[str] = None