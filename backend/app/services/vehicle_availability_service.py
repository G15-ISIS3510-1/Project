from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_
from typing import Optional, List
from app.db.models import VehicleAvailability, Vehicle
from app.schemas.vehicle_availability import VehicleAvailabilityCreate, VehicleAvailabilityUpdate
import uuid

class VehicleAvailabilityService:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def create_availability(self, availability_data: VehicleAvailabilityCreate) -> VehicleAvailability:
        """Crear una nueva disponibilidad de vehículo"""
        # Verificar que el vehículo existe
        vehicle = await self.get_vehicle_by_id(availability_data.vehicle_id)
        if not vehicle:
            raise ValueError("El vehículo no existe")
        
        # Verificar que no hay conflictos de horarios
        await self._check_schedule_conflicts(
            availability_data.vehicle_id,
            availability_data.start_ts,
            availability_data.end_ts
        )
        
        # Crear disponibilidad
        availability = VehicleAvailability(
            availability_id=str(uuid.uuid4()),
            vehicle_id=availability_data.vehicle_id,
            start_ts=availability_data.start_ts,
            end_ts=availability_data.end_ts,
            type=availability_data.type,
            notes=availability_data.notes
        )
        
        self.db.add(availability)
        await self.db.commit()
        await self.db.refresh(availability)
        return availability
    
    async def get_availability_by_id(self, availability_id: str) -> Optional[VehicleAvailability]:
        """Obtener disponibilidad por ID"""
        result = await self.db.execute(select(VehicleAvailability).where(VehicleAvailability.availability_id == availability_id))
        return result.scalar_one_or_none()
    
    async def get_availabilities_by_vehicle(self, vehicle_id: str) -> List[VehicleAvailability]:
        """Obtener todas las disponibilidades de un vehículo"""
        result = await self.db.execute(
            select(VehicleAvailability)
            .where(VehicleAvailability.vehicle_id == vehicle_id)
            .order_by(VehicleAvailability.start_ts)
        )
        return result.scalars().all()
    
    async def get_availabilities(self, skip: int = 0, limit: int = 100) -> List[VehicleAvailability]:
        """Obtener lista de disponibilidades con paginación"""
        result = await self.db.execute(
            select(VehicleAvailability)
            .offset(skip)
            .limit(limit)
            .order_by(VehicleAvailability.start_ts)
        )
        return result.scalars().all()
    
    async def get_available_vehicles(self, start_ts: str, end_ts: str) -> List[VehicleAvailability]:
        """Obtener vehículos disponibles en un rango de fechas"""
        from datetime import datetime
        start_datetime = datetime.fromisoformat(start_ts.replace('Z', '+00:00'))
        end_datetime = datetime.fromisoformat(end_ts.replace('Z', '+00:00'))
        
        result = await self.db.execute(
            select(VehicleAvailability)
            .where(
                and_(
                    VehicleAvailability.type == "available",
                    VehicleAvailability.start_ts <= start_datetime,
                    VehicleAvailability.end_ts >= end_datetime
                )
            )
            .order_by(VehicleAvailability.start_ts)
        )
        return result.scalars().all()
    
    async def update_availability(self, availability_id: str, availability_update: VehicleAvailabilityUpdate) -> Optional[VehicleAvailability]:
        """Actualizar disponibilidad"""
        availability = await self.get_availability_by_id(availability_id)
        if not availability:
            return None
        
        # Verificar conflictos si se actualizan las fechas
        update_data = availability_update.dict(exclude_unset=True)
        if "start_ts" in update_data or "end_ts" in update_data:
            start_ts = update_data.get("start_ts", availability.start_ts)
            end_ts = update_data.get("end_ts", availability.end_ts)
            await self._check_schedule_conflicts(
                availability.vehicle_id,
                start_ts,
                end_ts,
                exclude_id=availability_id
            )
        
        # Aplicar cambios
        for field, value in update_data.items():
            setattr(availability, field, value)
        
        await self.db.commit()
        await self.db.refresh(availability)
        return availability
    
    async def delete_availability(self, availability_id: str) -> bool:
        """Eliminar disponibilidad"""
        availability = await self.get_availability_by_id(availability_id)
        if not availability:
            return False
        
        await self.db.delete(availability)
        await self.db.commit()
        return True
    
    async def delete_availabilities_by_vehicle(self, vehicle_id: str) -> int:
        """Eliminar todas las disponibilidades de un vehículo"""
        result = await self.db.execute(
            select(VehicleAvailability).where(VehicleAvailability.vehicle_id == vehicle_id)
        )
        availabilities = result.scalars().all()
        
        for availability in availabilities:
            await self.db.delete(availability)
        
        await self.db.commit()
        return len(availabilities)
    
    async def _check_schedule_conflicts(self, vehicle_id: str, start_ts, end_ts, exclude_id: Optional[str] = None):
        """Verificar conflictos de horarios para un vehículo"""
        query = select(VehicleAvailability).where(
            and_(
                VehicleAvailability.vehicle_id == vehicle_id,
                VehicleAvailability.start_ts < end_ts,
                VehicleAvailability.end_ts > start_ts
            )
        )
        
        if exclude_id:
            query = query.where(VehicleAvailability.availability_id != exclude_id)
        
        result = await self.db.execute(query)
        conflicting = result.scalars().all()
        
        if conflicting:
            raise ValueError("Ya existe una disponibilidad que se superpone con el horario especificado")
    
    # Método auxiliar para verificar que el vehículo existe
    async def get_vehicle_by_id(self, vehicle_id: str) -> Optional[Vehicle]:
        """Obtener vehículo por ID (método auxiliar)"""
        result = await self.db.execute(select(Vehicle).where(Vehicle.vehicle_id == vehicle_id))
        return result.scalar_one_or_none()