from datetime import datetime, timedelta
from sqlalchemy import select, and_
from sqlalchemy.orm import Session
from typing import List, Dict, Any
from app.db.models import Booking, BookingStatus, User


class BookingReminderAnalytics:
    
    def __init__(self, db: Session):
        self.db = db
        self.reminder_threshold_hours = 1
    
    def get_bookings_needing_reminder(self) -> List[Dict[str, Any]]:
        now = datetime.now()
        threshold_time = now + timedelta(hours=self.reminder_threshold_hours)
        
        stmt = select(Booking).where(
            and_(
                Booking.status == BookingStatus.confirmed,
                Booking.start_ts > now,
                Booking.start_ts <= threshold_time
            )
        ).join(User, User.user_id == Booking.renter_id)
        
        bookings = self.db.execute(stmt).scalars().all()
        
        results = []
        for booking in bookings:
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
    
    def check_specific_booking(self, booking_id: str, user_id: str) -> Dict[str, Any]:
        now = datetime.now()
        
        stmt = select(Booking).where(
            and_(
                Booking.booking_id == booking_id,
                Booking.renter_id == user_id,
                Booking.status == BookingStatus.confirmed
            )
        )
        
        booking = self.db.execute(stmt).scalar_one_or_none()
        
        if not booking:
            return {
                'found': False,
                'message': 'Booking not found or not confirmed'
            }
        
        if booking.start_ts <= now:
            return {
                'found': True,
                'booking_id': booking.booking_id,
                'status': 'already_started',
                'should_notify': False,
                'message': 'Booking has already started'
            }
        
        time_until_start = booking.start_ts - now
        hours_remaining = time_until_start.total_seconds() / 3600
        minutes_remaining = int(time_until_start.total_seconds() / 60)
        
        reached_threshold = hours_remaining <= self.reminder_threshold_hours
        
        return {
            'found': True,
            'booking_id': booking.booking_id,
            'renter_id': booking.renter_id,
            'vehicle_id': booking.vehicle_id,
            'start_ts': booking.start_ts.isoformat(),
            'current_time': now.isoformat(),
            'hours_until_start': round(hours_remaining, 2),
            'minutes_until_start': minutes_remaining,
            'reached_threshold': reached_threshold,
            'should_notify': reached_threshold,
            'threshold_hours': self.reminder_threshold_hours,
            'time_remaining_formatted': self._format_time_remaining(time_until_start),
            'message': f"Reminder {'should' if reached_threshold else 'should not'} be sent"
        }
    
    def get_upcoming_bookings_by_user(
        self, 
        user_id: str, 
        hours_ahead: int = 24
    ) -> List[Dict[str, Any]]:
        now = datetime.now()
        future_time = now + timedelta(hours=hours_ahead)
        
        stmt = select(Booking).where(
            and_(
                Booking.renter_id == user_id,
                Booking.status == BookingStatus.confirmed,
                Booking.start_ts > now,
                Booking.start_ts <= future_time
            )
        ).order_by(Booking.start_ts)
        
        bookings = self.db.execute(stmt).scalars().all()
        
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
    
    def _format_time_remaining(self, time_delta: timedelta) -> str:
        total_seconds = int(time_delta.total_seconds())
        hours = total_seconds // 3600
        minutes = (total_seconds % 3600) // 60
        
        if hours > 0:
            return f"{hours}h {minutes}m"
        else:
            return f"{minutes}m"