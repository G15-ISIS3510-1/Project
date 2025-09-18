from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime

class VehicleAvailabilityBase(BaseModel):
    vehicle_id: str = Field(..., description="ID del vehículo")
    start_ts: datetime = Field(..., description="Fecha y hora de inicio")
    end_ts: datetime = Field(..., description="Fecha y hora de fin")
    type: str = Field(..., pattern="^(available|blocked|maintenance)$", description="Tipo de disponibilidad")
    notes: Optional[str] = Field(None, description="Notas adicionales")

class VehicleAvailabilityCreate(VehicleAvailabilityBase):
    # el id se genera automaticamente
    pass

class VehicleAvailabilityUpdate(BaseModel):
    start_ts: Optional[datetime] = Field(None, description="Fecha y hora de inicio")
    end_ts: Optional[datetime] = Field(None, description="Fecha y hora de fin")
    type: Optional[str] = Field(None, pattern="^(available|blocked|maintenance)$", description="Tipo de disponibilidad")
    notes: Optional[str] = Field(None, description="Notas adicionales")

class VehicleAvailabilityResponse(VehicleAvailabilityBase):
    availability_id: str
    
    class Config:
        from_attributes = True

class VehicleAvailabilityList(BaseModel):  # Para hacer la paginación
    availabilities: List[VehicleAvailabilityResponse]
    total: int
    page: int
    limit: int