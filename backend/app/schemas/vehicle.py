from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime

# Base schemas
class VehicleBase(BaseModel):
    make: str = Field(..., min_length=1, max_length=60)
    model: str = Field(..., min_length=1, max_length=60)
    year: int = Field(..., ge=1900, le=2030)  # Año entre 1900 y 2030
    plate: str = Field(..., min_length=1, max_length=32)
    seats: int = Field(..., ge=1, le=50)  # Entre 1 y 50 asientos
    transmission: str = Field(..., pattern="^(AT|MT|CVT|EV)$")
    fuel_type: str = Field(..., pattern="^(gas|diesel|hybrid|ev)$")
    mileage: int = Field(..., ge=0)  # Kilometraje no negativo
    status: str = Field(..., pattern="^(active|inactive|pending_review)$")
    lat: float = Field(..., ge=-90, le=90)  # Latitud válida
    lng: float = Field(..., ge=-180, le=180)  # Longitud válida
    photo_url: Optional[str] = None


class VehicleCreate(VehicleBase):
    pass
    
class VehicleUpdate(BaseModel):
    make: Optional[str] = Field(None, min_length=1, max_length=60)
    model: Optional[str] = Field(None, min_length=1, max_length=60)
    year: Optional[int] = Field(None, ge=1900, le=2030)
    plate: Optional[str] = Field(None, min_length=1, max_length=32)
    seats: Optional[int] = Field(None, ge=1, le=50)
    transmission: Optional[str] = Field(None, pattern="^(AT|MT|CVT|EV)$")
    fuel_type: Optional[str] = Field(None, pattern="^(gas|diesel|hybrid|ev)$")
    mileage: Optional[int] = Field(None, ge=0)
    status: Optional[str] = Field(None, pattern="^(active|inactive|pending_review)$")
    lat: Optional[float] = Field(None, ge=-90, le=90)
    lng: Optional[float] = Field(None, ge=-180, le=180)
    owner_id: Optional[str] = Field(None)  # Permitir actualizar owner_id si es necesario
    photo_url: Optional[str] = None

class VehicleResponse(VehicleBase):
    vehicle_id: str
    owner_id: str
    created_at: datetime
    
    class Config:
        from_attributes = True #puede crear instancias del modelo desde objetos SQLAlchemy
#Pydantic toma los atributos del objeto SQLAlchemy y los mapea a los campos del esquema:

class VehicleList(BaseModel):  # Para hacer la paginación
    vehicles: List[VehicleResponse]
    total: int
    page: int
    limit: int