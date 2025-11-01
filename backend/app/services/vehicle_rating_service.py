from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_, or_
from sqlalchemy.orm import selectinload
from typing import Optional, List
from datetime import datetime
import math
import uuid

from app.db.models import VehicleRating, Vehicle, User, VehicleAvailability, Pricing, Booking
from app.schemas.vehicle_rating import VehicleRatingCreate, VehicleRatingUpdate

class VehicleRatingService:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def create_rating(self, rating_data: VehicleRatingCreate, renter_id: str) -> VehicleRating:
        """Crear una nueva calificación"""
        # Verificar que no existe ya una calificación para esta reserva
        existing_rating = await self.get_rating_by_booking(rating_data.booking_id)
        if existing_rating:
            raise ValueError("Ya existe una calificación para esta reserva")
        
        rating = VehicleRating(
            rating_id=str(uuid.uuid4()),
            vehicle_id=rating_data.vehicle_id,
            booking_id=rating_data.booking_id,
            renter_id=renter_id,
            rating=rating_data.rating,
            comment=rating_data.comment
        )
        
        self.db.add(rating)
        await self.db.commit()
        await self.db.refresh(rating)
        return rating
    
    async def get_rating_by_id(self, rating_id: str) -> Optional[VehicleRating]:
        """Obtener calificación por ID"""
        result = await self.db.execute(
            select(VehicleRating)
            .options(selectinload(VehicleRating.vehicle))
            .options(selectinload(VehicleRating.renter))
            .where(VehicleRating.rating_id == rating_id)
        )
        return result.scalar_one_or_none()
    
    async def get_rating_by_booking(self, booking_id: str) -> Optional[VehicleRating]:
        """Obtener calificación por ID de reserva"""
        result = await self.db.execute(
            select(VehicleRating).where(VehicleRating.booking_id == booking_id)
        )
        return result.scalar_one_or_none()
    
    async def get_ratings_by_vehicle(self, vehicle_id: str, skip: int = 0, limit: int = 100) -> List[VehicleRating]:
        """Obtener todas las calificaciones de un vehículo"""
        result = await self.db.execute(
            select(VehicleRating)
            .options(selectinload(VehicleRating.renter))
            .where(VehicleRating.vehicle_id == vehicle_id)
            .order_by(VehicleRating.created_at.desc())
            .offset(skip)
            .limit(limit)
        )
        return result.scalars().all()
    
    async def get_average_rating_by_vehicle(self, vehicle_id: str) -> Optional[float]:
        """Obtener calificación promedio de un vehículo"""
        result = await self.db.execute(
            select(func.avg(VehicleRating.rating))
            .where(VehicleRating.vehicle_id == vehicle_id)
        )
        return result.scalar()
    
    async def get_rating_count_by_vehicle(self, vehicle_id: str) -> int:
        """Obtener número total de calificaciones de un vehículo"""
        result = await self.db.execute(
            select(func.count(VehicleRating.rating_id))
            .where(VehicleRating.vehicle_id == vehicle_id)
        )
        return result.scalar() or 0
    
    async def update_rating(self, rating_id: str, rating_update: VehicleRatingUpdate) -> Optional[VehicleRating]:
        """Actualizar una calificación existente"""
        rating = await self.get_rating_by_id(rating_id)
        if not rating:
            return None
        
        update_data = rating_update.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(rating, field, value)
        
        await self.db.commit()
        await self.db.refresh(rating)
        return rating
    
    async def delete_rating(self, rating_id: str) -> bool:
        """Eliminar una calificación"""
        rating = await self.get_rating_by_id(rating_id)
        if not rating:
            return False
        
        await self.db.delete(rating)
        await self.db.commit()
        return True
    
    def _calculate_distance(self, lat1: float, lng1: float, lat2: float, lng2: float) -> float:
        """Calcular distancia entre dos puntos en kilómetros usando fórmula de Haversine"""
        R = 6371  # Radio de la Tierra en kilómetros
        
        lat1_rad = math.radians(lat1)
        lng1_rad = math.radians(lng1)
        lat2_rad = math.radians(lat2)
        lng2_rad = math.radians(lng2)
        
        dlat = lat2_rad - lat1_rad
        dlng = lng2_rad - lng1_rad
        
        a = math.sin(dlat/2)**2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlng/2)**2
        c = 2 * math.asin(math.sqrt(a))
        
        return R * c
    
    async def get_top_rated_vehicles(
        self, 
        start_ts: str, 
        end_ts: str, 
        lat: float, 
        lng: float, 
        radius_km: float = 50.0,
        limit: int = 3,
        min_rating: float = 3.0
    ) -> List[dict]:
        """Obtener los vehículos con mayor calificación disponibles en fechas y ubicación específicas"""
        
        # Convertir fechas
        start_datetime = datetime.fromisoformat(start_ts.replace('Z', '+00:00'))
        end_datetime = datetime.fromisoformat(end_ts.replace('Z', '+00:00'))
        
        # Subconsulta para obtener calificación promedio por vehículo
        avg_rating_subquery = (
            select(
                VehicleRating.vehicle_id,
                func.avg(VehicleRating.rating).label('avg_rating'),
                func.count(VehicleRating.rating_id).label('total_ratings')
            )
            .group_by(VehicleRating.vehicle_id)
            .having(func.avg(VehicleRating.rating) >= min_rating)
        ).subquery()
        
        # Query principal
        query = (
            select(
                Vehicle,
                User.name.label('owner_name'),
                Pricing.daily_price,
                Pricing.currency,
                avg_rating_subquery.c.avg_rating,
                avg_rating_subquery.c.total_ratings
            )
            .join(User, Vehicle.owner_id == User.user_id)
            .join(Pricing, Vehicle.vehicle_id == Pricing.vehicle_id)
            .join(avg_rating_subquery, Vehicle.vehicle_id == avg_rating_subquery.c.vehicle_id)
            .where(
                and_(
                    Vehicle.status == "active",
                    # Verificar disponibilidad
                    Vehicle.vehicle_id.in_(
                        select(VehicleAvailability.vehicle_id)
                        .where(
                            and_(
                                VehicleAvailability.type == "available",
                                VehicleAvailability.start_ts <= start_datetime,
                                VehicleAvailability.end_ts >= end_datetime
                            )
                        )
                    )
                )
            )
            .order_by(avg_rating_subquery.c.avg_rating.desc())
            .limit(limit * 3)  # Obtener más para filtrar por distancia
        )
        
        result = await self.db.execute(query)
        vehicles_data = result.all()
        
        # Filtrar por distancia y limitar resultados
        filtered_vehicles = []
        for vehicle_data in vehicles_data:
            vehicle = vehicle_data[0]
            distance = self._calculate_distance(lat, lng, vehicle.lat, vehicle.lng)
            
            if distance <= radius_km:
                filtered_vehicles.append({
                    'vehicle_id': vehicle.vehicle_id,
                    'make': vehicle.make,
                    'model': vehicle.model,
                    'year': vehicle.year,
                    'seats': vehicle.seats,
                    'transmission': vehicle.transmission,
                    'fuel_type': vehicle.fuel_type,
                    'mileage': vehicle.mileage,
                    'lat': vehicle.lat,
                    'lng': vehicle.lng,
                    'photo_url': vehicle.photo_url,
                    'daily_price': vehicle_data[2],  # Pricing.daily_price
                    'currency': vehicle_data[3],     # Pricing.currency
                    'average_rating': float(vehicle_data[4]),  # avg_rating
                    'total_ratings': vehicle_data[5],  # total_ratings
                    'distance_km': round(distance, 2),
                    'owner_name': vehicle_data[1]  # owner_name
                })
                
                if len(filtered_vehicles) >= limit:
                    break
        
        return filtered_vehicles
