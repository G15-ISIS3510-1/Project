from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class VehicleRatingBase(BaseModel):
    vehicle_id: str = Field(..., description="ID del vehículo")
    booking_id: str = Field(..., description="ID de la reserva")
    rating: float = Field(..., ge=1.0, le=5.0, description="Calificación de 1.0 a 5.0")
    comment: Optional[str] = Field(None, description="Comentario opcional")

class VehicleRatingCreate(VehicleRatingBase):
    pass

class VehicleRatingUpdate(BaseModel):
    rating: Optional[float] = Field(None, ge=1.0, le=5.0, description="Calificación de 1.0 a 5.0")
    comment: Optional[str] = Field(None, description="Comentario opcional")

class VehicleRatingResponse(VehicleRatingBase):
    rating_id: str
    renter_id: str
    created_at: datetime
    
    class Config:
        from_attributes = True

class VehicleRatingWithDetails(VehicleRatingResponse):
    renter_name: str
    vehicle_make: str
    vehicle_model: str
    vehicle_year: int

class TopRatedVehicleSearch(BaseModel):
    start_ts: str = Field(..., description="Fecha y hora de inicio (ISO format)")
    end_ts: str = Field(..., description="Fecha y hora de fin (ISO format)")
    lat: float = Field(..., ge=-90, le=90, description="Latitud del usuario")
    lng: float = Field(..., ge=-180, le=180, description="Longitud del usuario")
    radius_km: float = Field(50.0, ge=1.0, le=500.0, description="Radio de búsqueda en kilómetros")
    limit: int = Field(3, ge=1, le=20, description="Número máximo de vehículos a retornar")
    min_rating: float = Field(3.0, ge=1.0, le=5.0, description="Calificación mínima requerida")

class TopRatedVehicleResponse(BaseModel):
    vehicle_id: str
    make: str
    model: str
    year: int
    seats: int
    transmission: str
    fuel_type: str
    mileage: int
    lat: float
    lng: float
    photo_url: Optional[str]
    daily_price: float
    currency: str
    average_rating: float
    total_ratings: int
    distance_km: float
    owner_name: str
