from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import Optional, List
from app.db.models import Vehicle
from app.schemas.vehicle import VehicleCreate, VehicleUpdate
import uuid

class VehicleService:
    def __init__(self, db: AsyncSession):
        self.db = db
        
    async def create_vehicle(self, vehicle_data: VehicleCreate, owner_id: str) -> Vehicle:
        """Crear un nuevo vehículo"""
        # Verificar si la placa ya existe
        existing_vehicle = await self.get_vehicle_by_plate(vehicle_data.plate)
        if existing_vehicle:
            raise ValueError("El vehículo con esa placa ya está registrado")
        
        # Crear vehículo
        vehicle = Vehicle(
            vehicle_id=str(uuid.uuid4()),
            owner_id=owner_id,
            make=vehicle_data.make,
            model=vehicle_data.model,
            year=vehicle_data.year,
            plate=vehicle_data.plate,
            seats=vehicle_data.seats,
            transmission=vehicle_data.transmission,
            fuel_type=vehicle_data.fuel_type,
            mileage=vehicle_data.mileage,
            status=vehicle_data.status,
            lat=vehicle_data.lat,
            lng=vehicle_data.lng,
            photo_url=vehicle_data.photo_url
        )
        
        self.db.add(vehicle)
        await self.db.commit()
        await self.db.refresh(vehicle)
        return vehicle 
    
    
    async def get_vehicle_by_plate(self,placa:str)->Optional[Vehicle]:
      result = await self.db.execute(select(Vehicle).where(Vehicle.plate==placa))
      return result.scalar_one_or_none()    
  #   	1.	Si la consulta no devuelve nada → retorna None.
	# 2.	Si la consulta devuelve exactamente una fila → retorna el valor escalar de esa fila (normalmente el primer campo o el objeto que pediste).
	# 3.	Si devuelve más de una fila → lanza una excepción (MultipleResultsFound), porque se espera como máximo uno.
  
    async def get_vehicle_by_id(self, vehicle_id: str) -> Optional[Vehicle]:
        """Obtener vehículo por ID"""
        result = await self.db.execute(select(Vehicle).where(Vehicle.vehicle_id == vehicle_id))
        return result.scalar_one_or_none()

    async def get_vehicles(self, skip: int = 0, limit: int = 100) -> List[Vehicle]:
        """Obtener lista de vehículos con paginación"""
        result = await self.db.execute(select(Vehicle).offset(skip).limit(limit))
        return result.scalars().all()
    
    async def get_vehicles_by_owner(self, owner_id: str) -> List[Vehicle]:
        """Obtener vehículos de un propietario específico"""
        result = await self.db.execute(select(Vehicle).where(Vehicle.owner_id == owner_id))
        return result.scalars().all()
    
    async def update_vehicle(self, vehicle_id: str, vehicle_update: VehicleUpdate) -> Optional[Vehicle]:
        """Actualizar vehículo"""
        vehicle = await self.get_vehicle_by_id(vehicle_id)
        if not vehicle:
            return None
        
        # Actualizar solo campos proporcionados
        update_data = vehicle_update.dict(exclude_unset=True)
        
        # Validaciones de negocio
        if "plate" in update_data:
            existing_vehicle = await self.get_vehicle_by_plate(update_data["plate"])
            if existing_vehicle and existing_vehicle.vehicle_id != vehicle_id:
                raise ValueError("La placa ya está en uso por otro vehículo")
        
        # Aplicar cambios
        for field, value in update_data.items():
            setattr(vehicle, field, value)
        
        await self.db.commit()
        await self.db.refresh(vehicle)
        return vehicle
    
    async def delete_vehicle(self, vehicle_id: str) -> bool:
        """Eliminar vehículo (soft delete cambiando status a inactive)"""
        vehicle = await self.get_vehicle_by_id(vehicle_id)
        if not vehicle:
            return False
        
        vehicle.status = "inactive"
        await self.db.commit()
        return True