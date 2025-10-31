from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.orm import Session

from sqlalchemy import func, select

from app.db import models

from app.db import get_db
from app.services.analytics_service import BookingReminderAnalytics 
from app.schemas.analytics_schemas import (
    BookingReminderListResponse,
    BookingReminderStatusResponse,
    UpcomingBookingsListResponse
)

router = APIRouter()


@router.get(
    "/bookings/reminders",
    response_model=BookingReminderListResponse,
    summary="Obtener reservas que necesitan recordatorio",
    description="Devuelve todas las reservas confirmadas que comienzan en la próxima hora"
)
async def get_bookings_needing_reminders(
    db: Session = Depends(get_db)
):
    analytics = BookingReminderAnalytics(db)
    bookings = await analytics.get_bookings_needing_reminder()
    
    return {
        "bookings": bookings,
        "threshold_hours": analytics.reminder_threshold_hours,
        "total_count": len(bookings)
    }


@router.get(
    "/bookings/{booking_id}/reminder-status",
    response_model=BookingReminderStatusResponse,
    summary="Verificar estado de recordatorio de una reserva",
    description="Verifica si una reserva específica ha alcanzado el umbral para notificación"
)
async def check_booking_reminder(
    booking_id: str,
    user_id: str = Query(..., description="ID del usuario que realizó la reserva"),
    db: Session = Depends(get_db)
):
    analytics = BookingReminderAnalytics(db)
    result = await analytics.check_specific_booking(booking_id, user_id)
    
    return result


@router.get(
    "/users/{user_id}/upcoming-bookings",
    response_model=UpcomingBookingsListResponse,
    summary="Obtener próximas reservas de un usuario",
    description="Lista todas las reservas confirmadas próximas de un usuario en una ventana de tiempo"
)
async def get_user_upcoming_bookings(
    user_id: str,
    hours_ahead: int = Query(
        default=24,
        ge=1,
        le=168,
        description="Horas hacia adelante para buscar reservas (1-168)"
    ),
    db: Session = Depends(get_db)
):
    analytics = BookingReminderAnalytics(db)
    bookings = await analytics.get_upcoming_bookings_by_user(user_id, hours_ahead)
    
    return {
        "user_id": user_id,
        "bookings": bookings,
        "hours_ahead": hours_ahead,
        "total_count": len(bookings)
    }


@router.get(
    "/bookings/reminders/summary",
    summary="Resumen de recordatorios",
    description="Estadísticas generales sobre recordatorios de reservas"
)
async def get_reminders_summary(
    db: Session = Depends(get_db)
):
    analytics = BookingReminderAnalytics(db)
    bookings = await analytics.get_bookings_needing_reminder()
    
    if not bookings:
        return {
            "total_reminders": 0,
            "average_minutes_until_start": 0,
            "closest_booking": None
        }
    
    minutes_list = [b['minutes_until_start'] for b in bookings]
    avg_minutes = sum(minutes_list) / len(minutes_list)
    
    closest_booking = min(bookings, key=lambda x: x['minutes_until_start'])
    
    return {
        "total_reminders": len(bookings),
        "average_minutes_until_start": round(avg_minutes, 2),
        "closest_booking": {
            "booking_id": closest_booking['booking_id'],
            "minutes_until_start": closest_booking['minutes_until_start'],
            "time_remaining": closest_booking['time_remaining_formatted']
        }
    }

@router.get("/demand-peaks")
async def get_demand_peaks(db: Session = Depends(get_db)):
    stmt = (
        select(
            models.Vehicle.vehicle_id,
            models.Vehicle.lat,
            models.Vehicle.lng,
            func.count(models.Booking.booking_id).label("total_rentals"),
        )
        .join(models.Booking, models.Vehicle.vehicle_id == models.Booking.vehicle_id)
        .group_by(models.Vehicle.vehicle_id)
        .order_by(func.count(models.Booking.booking_id).desc())
    )

    result = await db.execute(stmt)
    results = result.all()

    return [
        {
            "vehicle_id": r.vehicle_id,
            "lat": r.lat,
            "lng": r.lng,
            "total_rentals": r.total_rentals
        }
        for r in results
    ]

@router.get("/owner-income")
async def get_owner_income(db: Session = Depends(get_db)):
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
    results = result.all()

    return [
        {
            "owner_id": r.owner_id,
            "month": r.month.strftime("%Y-%m") if r.month else None,
            "total_income": round(r.total_income, 2) if r.total_income else 0.0,
        }
        for r in results
    ]

@router.get("/demand-peaks-extended")
async def get_demand_peaks_extended(db: Session = Depends(get_db)):
    stmt = (
        select(
            func.round(models.Vehicle.lat, 1).label("lat_zone"),
            func.round(models.Vehicle.lng, 1).label("lon_zone"),
            func.date_trunc('hour', models.Booking.start_ts).label("hour_slot"),
            models.Vehicle.make.label("make"),
            models.Vehicle.year.label("year"),
            models.Vehicle.fuel_type.label("fuel_type"),
            models.Vehicle.transmission.label("transmission"),
            func.count(models.Booking.booking_id).label("total_rentals"),
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
    results = result.all()

    return [
        {
            "lat_zone": r.lat_zone,
            "lon_zone": r.lon_zone,
            "hour_slot": r.hour_slot.strftime("%H") if hasattr(r.hour_slot, "strftime") else str(r.hour_slot),
            "make": r.make,
            "year": r.year,
            "fuel_type": r.fuel_type,
            "transmission": r.transmission,
            "total_rentals": r.total_rentals,
        }
        for r in results
    ]
