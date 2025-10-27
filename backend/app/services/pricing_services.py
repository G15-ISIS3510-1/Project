from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from typing import Optional, List, Dict, Any
from app.db.models import Pricing, Vehicle
from app.schemas.pricing import PricingCreate, PricingUpdate
import uuid

class PricingService:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def create_pricing(self, pricing_data: PricingCreate, vehicle_id: str) -> Pricing:
        """Crear un nuevo pricing para un vehículo"""
        # Verificar si el vehículo ya tiene pricing
        existing_pricing = await self.get_pricing_by_vehicle_id(vehicle_id)
        if existing_pricing:
            raise ValueError("El vehículo ya tiene un pricing configurado")
        
        # Verificar que el vehículo existe
        vehicle = await self.get_vehicle_by_id(vehicle_id)
        if not vehicle:
            raise ValueError("El vehículo no existe")
        
        # Crear pricing
        pricing = Pricing(
            pricing_id=str(uuid.uuid4()),
            vehicle_id=vehicle_id,
            daily_price=pricing_data.daily_price,
            min_days=pricing_data.min_days,
            max_days=pricing_data.max_days,
            currency=pricing_data.currency
        )
        
        self.db.add(pricing)
        await self.db.commit()
        await self.db.refresh(pricing)
        return pricing
    
    async def get_pricing_by_id(self, pricing_id: str) -> Optional[Pricing]:
        """Obtener pricing por ID"""
        result = await self.db.execute(
            select(Pricing).where(Pricing.pricing_id == pricing_id)
        )
        return result.scalar_one_or_none()
    
    async def get_pricing_by_vehicle_id(self, vehicle_id: str) -> Optional[Pricing]:
        """Obtener pricing por vehicle_id"""
        result = await self.db.execute(
            select(Pricing).where(Pricing.vehicle_id == vehicle_id)
        )
        return result.scalar_one_or_none()
    
    async def get_pricings(self, skip: int = 0, limit: int = 100) -> Dict[str, Any]:
        """
        Obtener lista de pricings con paginación.
        Devuelve { items, total, skip, limit }.
        """
        # total
        total_q = await self.db.execute(
            select(func.count(Pricing.pricing_id))
        )
        total = total_q.scalar() or 0

        # page
        page_q = await self.db.execute(
            select(Pricing).offset(skip).limit(limit)
        )
        rows = page_q.scalars().all()

        return {
            "items": rows,
            "total": total,
            "skip": skip,
            "limit": limit,
        }
    
    async def update_pricing(self, pricing_id: str, pricing_update: PricingUpdate) -> Optional[Pricing]:
        """Actualizar pricing"""
        pricing = await self.get_pricing_by_id(pricing_id)
        if not pricing:
            return None
        
        # Actualizar solo campos proporcionados
        update_data = pricing_update.dict(exclude_unset=True)
        
        # Aplicar cambios
        for field, value in update_data.items():
            setattr(pricing, field, value)
        
        await self.db.commit()
        await self.db.refresh(pricing)
        return pricing
    
    async def update_pricing_by_vehicle_id(self, vehicle_id: str, pricing_update: PricingUpdate) -> Optional[Pricing]:
        """Actualizar pricing por vehicle_id"""
        pricing = await self.get_pricing_by_vehicle_id(vehicle_id)
        if not pricing:
            return None
        
        # Actualizar solo campos proporcionados
        update_data = pricing_update.dict(exclude_unset=True)
        
        for field, value in update_data.items():
            setattr(pricing, field, value)
        
        await self.db.commit()
        await self.db.refresh(pricing)
        return pricing
    
    async def delete_pricing(self, pricing_id: str) -> bool:
        """Eliminar pricing"""
        pricing = await self.get_pricing_by_id(pricing_id)
        if not pricing:
            return False
        
        await self.db.delete(pricing)
        await self.db.commit()
        return True
    
    async def delete_pricing_by_vehicle_id(self, vehicle_id: str) -> bool:
        """Eliminar pricing por vehicle_id"""
        pricing = await self.get_pricing_by_vehicle_id(vehicle_id)
        if not pricing:
            return False
        
        await self.db.delete(pricing)
        await self.db.commit()
        return True
    
    # Método auxiliar para verificar que el vehículo existe
    async def get_vehicle_by_id(self, vehicle_id: str) -> Optional[Vehicle]:
        """Obtener vehículo por ID (método auxiliar)"""
        result = await self.db.execute(
            select(Vehicle).where(Vehicle.vehicle_id == vehicle_id)
        )
        return result.scalar_one_or_none()
