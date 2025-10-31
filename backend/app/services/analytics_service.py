from datetime import datetime, timedelta
from sqlalchemy import select, and_, func
from sqlalchemy.orm import Session
from typing import List, Dict, Any
from fastapi import HTTPException
from app.db.models import Booking, BookingStatus, User 

from sqlalchemy.orm import Session
from sqlalchemy import func, extract
from app.db import models

class BookingReminderAnalytics:
    
    def __init__(self, db: Session):
        self.db = db
        self.reminder_threshold_hours = 1
    
    # Esta función debe ser asíncrona si usa una AsyncSession
    async def get_bookings_needing_reminder(self) -> List[Dict[str, Any]]:
        now = datetime.now()
        threshold_time = now + timedelta(hours=self.reminder_threshold_hours)
        
        stmt = select(Booking).where(
            and_(
                Booking.status == BookingStatus.confirmed,
                Booking.start_ts > now,
                Booking.start_ts <= threshold_time
            )
        ).join(User, User.user_id == Booking.renter_id)
        
        bookings = (await self.db.execute(stmt)).scalars().all()
        
        results = []
        for booking in bookings:
            if not booking.start_ts:
                continue 

            time_until_start = booking.start_ts - now
            minutes_remaining = int(time_until_start.total_seconds() / 60)
            
            results.append({
                'booking_id': booking.booking_id,
                'renter_id': booking.renter_id,
                'vehicle_id': booking.vehicle_id,
                'start_ts': booking.start_ts,
                'minutes_until_start': minutes_remaining,
                'should_notify': True,
                'time_remaining_formatted': self._format_time_remaining(time_until_start)
            })
        
        return results
    
    # Esta función debe ser asíncrona si usa una AsyncSession
    async def check_specific_booking(self, booking_id: str, user_id: str) -> Dict[str, Any]:
        now = datetime.now()
        
        stmt = select(Booking).where(
            and_(
                Booking.booking_id == booking_id,
                Booking.renter_id == user_id,
                Booking.status == BookingStatus.confirmed
            )
        )
        
        booking = (await self.db.execute(stmt)).scalar_one_or_none()
        
        if not booking:
            return {
                'found': False,
                'message': 'Booking not found or not confirmed'
            }
        
        if booking.start_ts is None or booking.start_ts <= now:
            return {
                'found': True,
                'booking_id': booking.booking_id,
                'status': 'already_started',
                'should_notify': False,
                'message': 'Booking has already started'
            }
        
        time_until_start = booking.start_ts - now
        hours_remaining = time_until_start.total_seconds() / 3600
        
        reached_threshold = hours_remaining <= self.reminder_threshold_hours
        
        return {
            'found': True,
            'booking_id': booking.booking_id,
            'renter_id': booking.renter_id,
            'vehicle_id': booking.vehicle_id,
            'start_ts': booking.start_ts.isoformat(),
            'current_time': now.isoformat(),
            'hours_until_start': round(hours_remaining, 2),
            'reached_threshold': reached_threshold,
            'should_notify': reached_threshold,
            'threshold_hours': self.reminder_threshold_hours,
            'time_remaining_formatted': self._format_time_remaining(time_until_start),
            'message': f"Reminder {'should' if reached_threshold else 'should not'} be sent"
        }
    
    # Esta función debe ser asíncrona si usa una AsyncSession
    async def get_upcoming_bookings_by_user(
        self, 
        user_id: str, 
        hours_ahead: int = 24
    ) -> List[Dict[str, Any]]:
        
        try:
            now = datetime.now()
            future_time = now + timedelta(hours=hours_ahead)
            
            STATUS_CONFIRMED_VALUE = 'confirmed' 
            
            stmt = select(Booking).where(
                and_(
                    Booking.renter_id == user_id,
                    # Usamos el valor literal de string para el status
                    Booking.status == STATUS_CONFIRMED_VALUE, 
                    # Filtramos las filas que tienen fechas nulas
                    Booking.start_ts.isnot(None),
                    Booking.end_ts.isnot(None), 
                    Booking.start_ts > now,
                    Booking.start_ts <= future_time
                )
            ).order_by(Booking.start_ts)
            
            bookings = (await self.db.execute(stmt)).scalars().all()
            
            results = []
            for booking in bookings:
                time_until_start = booking.start_ts - now 
                hours_remaining = time_until_start.total_seconds() / 3600
                
                results.append({
                    'booking_id': booking.booking_id,
                    'vehicle_id': booking.vehicle_id,
                    'start_ts': booking.start_ts.isoformat(),
                    'end_ts': booking.end_ts.isoformat(),
                    'hours_until_start': round(hours_remaining, 2),
                    'reached_threshold': hours_remaining <= self.reminder_threshold_hours,
                    'time_remaining_formatted': self._format_time_remaining(time_until_start)
                })
            
            return results

        except Exception as e:
            print(f"CRITICAL ERROR in get_upcoming_bookings_by_user for user {user_id}: {e}")
            
            raise HTTPException(
                status_code=503, 
                detail="Service Unavailable: Database connection failed or internal processing error."
            )
            
    
    def _format_time_remaining(self, time_delta: timedelta) -> str:
        total_seconds = int(time_delta.total_seconds())
        hours = total_seconds // 3600
        minutes = (total_seconds % 3600) // 60
        
        if hours > 0:
            return f"{hours}h {minutes}m"
        else:
            return f"{minutes}m"
        
    async def compute_demand_peaks(db: Session):
        stmt = (
            select(
                func.round(models.Booking.pickup_latitude, 1).label("lat_zone"),
                func.round(models.Booking.pickup_longitude, 1).label("lon_zone"),
                func.count(models.Booking.id).label("rentals"),
            )
            .group_by("lat_zone", "lon_zone")
            .order_by(func.count(models.Booking.id).desc())
        )
        result = await db.execute(stmt)
        return result.all()
    
    async def get_owner_income(db: Session):
        stmt = (
            select(
                models.Booking.host_id.label("owner_id"),
                func.date_trunc("month", models.Payment.created_at).label("month"),
                func.sum(models.Payment.amount).label("total_income"),
            )
            .join(models.Payment, models.Payment.booking_id == models.Booking.booking_id)
            .where(models.Payment.status == models.PaymentStatus.captured)
            .group_by("owner_id", "month")
            .order_by("owner_id")
        )
        result = await db.execute(stmt)
        return result.all()

    async def get_demand_peaks_extended(db: Session):
        stmt = (
            select(
                func.round(models.Vehicle.lat, 1).label("lat_zone"),
                func.round(models.Vehicle.lng, 1).label("lon_zone"),
                func.date_trunc('hour', models.Booking.start_ts).label("hour_slot"),
                models.Vehicle.make.label("make"),
                models.Vehicle.year.label("year"),
                models.Vehicle.fuel_type.label("fuel_type"),
                models.Vehicle.transmission.label("transmission"),
                func.count(models.Booking.booking_id).label("rentals"),
            )
            .join(models.Booking, models.Vehicle.vehicle_id == models.Booking.vehicle_id)
            .where(models.Booking.status == models.BookingStatus.completed)
            .group_by(
                func.round(models.Vehicle.lat, 1),
                func.round(models.Vehicle.lng, 1),
                func.date_trunc('hour', models.Booking.start_ts),
                models.Vehicle.make,
                models.Vehicle.year,
                models.Vehicle.fuel_type,
                models.Vehicle.transmission,
            )
            .order_by(func.count(models.Booking.booking_id).desc())
        )

        result = await db.execute(stmt)
        return result.all()