from fastapi import APIRouter, Depends, Query, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from datetime import datetime, timedelta

from sqlalchemy import func, select

from app.db import models
from app.db import get_db
from app.db.models import User
from app.routers.users import get_current_user_from_token
from app.services.analytics_service import BookingReminderAnalytics 
from app.services.analytics_service import fees_taxes_average
from app.services.feature_tracking import (
    get_low_usage_features as get_low_usage_features_service,
    get_feature_usage_stats,
    get_chat_time_stats,
    log_feature_usage,
)
from app.schemas.analytics_schemas import (
    BookingReminderListResponse,
    BookingReminderStatusResponse,
    UpcomingBookingsListResponse,
    FeesTaxesAverageResponse
    FeatureUsageLogRequest,
    FeatureUsageLogResponse,
)

router = APIRouter()


@router.get(
    "/bookings/reminders",
    response_model=BookingReminderListResponse,
    summary="Obtener reservas que necesitan recordatorio",
    description="Devuelve todas las reservas confirmadas que comienzan en la próxima hora"
)
async def get_bookings_needing_reminders(
    db: AsyncSession = Depends(get_db)
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
    db: AsyncSession = Depends(get_db)
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
    db: AsyncSession = Depends(get_db)
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
    db: AsyncSession = Depends(get_db)
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
async def get_demand_peaks(db: AsyncSession = Depends(get_db)):
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
async def get_owner_income(db: AsyncSession = Depends(get_db)):
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
async def get_demand_peaks_extended(db: AsyncSession = Depends(get_db)):
    try:
        print(">>> Ejecutando query /demand-peaks-extended")

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

        print(">>> Ejecutando statement SQL...")
        result = await db.execute(stmt)
        print(">>> Query ejecutada correctamente")

        results = result.all()
        print(f">>> Se obtuvieron {len(results)} filas")

        return [
            {
                "lat_zone": r.lat_zone,
                "lon_zone": r.lon_zone,
                "hour_slot": str(r.hour_slot),
                "make": r.make,
                "year": r.year,
                "fuel_type": r.fuel_type,
                "transmission": r.transmission,
                "total_rentals": r.total_rentals,
            }
            for r in results
        ]

    except Exception as e:
        import traceback
        print("ERROR en /demand-peaks-extended")
        print(traceback.format_exc())
        raise HTTPException(status_code=500, detail=str(e))

# Sprint 4
@router.get("/insurance/daily-costs")
async def get_insurance_daily_costs(db: AsyncSession = Depends(get_db)):

    stmt = (
        select(
            models.InsurancePlan.insurance_plan_id,
            models.InsurancePlan.name,
            models.InsurancePlan.daily_cost,
        )
        .where(models.InsurancePlan.active == True)
        .order_by(models.InsurancePlan.daily_cost.desc())
    )

    result = await db.execute(stmt)
    rows = result.all()

    return [
        {
            "insurance_plan_id": r.insurance_plan_id,
            "name": r.name,
            "daily_cost": r.daily_cost,
        }
        for r in rows
    ]

@router.get("/vehicles/recent-price-updates")
async def get_recent_price_updates(db: AsyncSession = Depends(get_db)):

    seven_days_ago = datetime.utcnow() - timedelta(days=7)

    stmt = (
        select(
            models.Pricing.pricing_id,
            models.Pricing.vehicle_id,
            models.Pricing.daily_price,
            models.Pricing.last_updated,
        )
        .where(models.Pricing.last_updated >= seven_days_ago)
        .order_by(models.Pricing.daily_price.desc())
    )

    result = await db.execute(stmt)
    rows = result.all()

    return [
        {
            "pricing_id": r.pricing_id,
            "vehicle_id": r.vehicle_id,
            "daily_price": r.daily_price,
            "last_updated": r.last_updated,
        }
        for r in rows
    ]

@router.get("/bookings/fees-taxes")
async def get_fees_and_taxes(db: AsyncSession = Depends(get_db)):

    stmt = (
        select(
            models.Booking.booking_id,
            models.Booking.daily_price_snapshot,
            models.Booking.insurance_daily_cost_snapshot,
            models.Booking.subtotal,
            models.Booking.fees,
            models.Booking.taxes,
            models.Booking.total,
            models.Booking.currency,
        )
        .order_by(models.Booking.total.desc())
    )

    result = await db.execute(stmt)
    rows = result.all()

    return [
        {
            "booking_id": r.booking_id,
            "daily_price_snapshot": r.daily_price_snapshot,
            "insurance_daily_cost_snapshot": r.insurance_daily_cost_snapshot,
            "subtotal": r.subtotal,
            "fees": r.fees,
            "taxes": r.taxes,
            "total": r.total,
            "currency": r.currency,
        }
        for r in rows
    ]
#

@router.get(
    "/features/low-usage",
    summary="Funcionalidades con bajo uso",
    description="Obtiene las funcionalidades que se usan menos de N veces por semana por usuario en promedio"
)
async def get_low_usage_features(
    weeks: int = Query(default=4, ge=1, le=52, description="Número de semanas a considerar (default: 4)"),
    threshold: float = Query(default=2.0, ge=0.1, description="Umbral mínimo de usos por semana por usuario (default: 2.0)"),
    db: AsyncSession = Depends(get_db)
):
    """
    Devuelve las funcionalidades que se usan menos de 'threshold' veces por semana por usuario
    en promedio durante las últimas 'weeks' semanas.
    """
    features = await get_low_usage_features_service(db, weeks=weeks, threshold=threshold)
    
    return {
        "features": features,
        "weeks": weeks,
        "threshold": threshold,
        "total_count": len(features)
    }


@router.get(
    "/features/usage-stats",
    summary="Estadísticas de uso de funcionalidades",
    description="Obtiene estadísticas generales de uso de funcionalidades"
)
async def get_feature_usage_statistics(
    feature_name: str = Query(default=None, description="Filtrar por nombre de funcionalidad específica"),
    weeks: int = Query(default=4, ge=1, le=52, description="Número de semanas a considerar"),
    db: AsyncSession = Depends(get_db)
):
    """
    Devuelve estadísticas de uso de funcionalidades.
    """
    stats = await get_feature_usage_stats(db, feature_name=feature_name, weeks=weeks)
    
    return {
        "stats": stats,
        "weeks": weeks,
        "feature_filter": feature_name,
        "total_features": len(stats)
    }


@router.get(
    "/fees-taxes-average",
    response_model=FeesTaxesAverageResponse,
    summary="Promedio de fees + taxes por booking",
    description="Calcula el promedio de fees y taxes sumados sobre todas las reservas confirmadas/activas/completadas."
)
async def get_fees_taxes_average(db: AsyncSession = Depends(get_db)):
    average, sample_size = await fees_taxes_average(db)
    return {
        "average": round(average, 2),
        "sample_size": sample_size
    }
  
 @router.get(
    "/features/chat-time-stats",
    summary="Estadísticas de tiempo en chat",
    description="Obtiene estadísticas detalladas del tiempo que los usuarios pasan en el chat antes de cambiar de sección."
)
async def get_chat_time_statistics(
    weeks: int = Query(default=4, ge=1, le=52, description="Número de semanas a considerar"),
    db: AsyncSession = Depends(get_db)
):
    """
    Devuelve estadísticas específicas del tiempo en chat, incluyendo duración promedio, mínima, máxima y mediana.
    """
    stats = await get_chat_time_stats(db, weeks=weeks)
    
    if stats is None:
        return {
            "total_sessions": 0,
            "unique_users": 0,
            "avg_duration_seconds": 0.0,
            "min_duration_seconds": 0.0,
            "max_duration_seconds": 0.0,
            "median_duration_seconds": 0.0,
            "weeks": weeks
        }
    
    return {**stats, "weeks": weeks}


@router.post(
    "/features/usage-log",
    response_model=FeatureUsageLogResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Registrar evento de uso de una funcionalidad",
    description="Permite registrar eventos personalizados como el tiempo pasado en el chat."
)
async def create_feature_usage_log(
    payload: FeatureUsageLogRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """
    Endpoint público para que los clientes móviles reporten métricas específicas.
    """
    import logging
    logger = logging.getLogger(__name__)
    
    try:
        logger.info(f"Received feature usage log request: user_id={current_user.user_id}, feature={payload.feature_name}")
        
        enriched_metadata = dict(payload.metadata) if payload.metadata else {}
        
        if payload.duration_ms is not None:
            enriched_metadata["duration_ms"] = payload.duration_ms
        if payload.origin_route:
            enriched_metadata.setdefault("origin_route", payload.origin_route)
        if payload.destination_route:
            enriched_metadata.setdefault("destination_route", payload.destination_route)
        
        # Asegurar que todos los valores en metadata sean serializables a JSON
        serializable_metadata = {}
        for key, value in enriched_metadata.items():
            if value is not None:
                # Convertir tipos que no son directamente JSON serializables
                if isinstance(value, (int, float, str, bool, type(None))):
                    serializable_metadata[key] = value
                else:
                    serializable_metadata[key] = str(value)
        
        usage_log = await log_feature_usage(
            db=db,
            user_id=current_user.user_id,
            feature_name=payload.feature_name,
            duration_seconds=payload.duration_seconds,
            metadata=serializable_metadata if serializable_metadata else None
        )
        
        if usage_log is None:
            logger.error(f"Failed to create feature usage log for user {current_user.user_id}, feature {payload.feature_name}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="No se pudo registrar el evento de uso. Revisa los logs del servidor para más detalles."
            )

        logger.info(f"Successfully created feature usage log with ID: {usage_log.id}")
        return FeatureUsageLogResponse(
            id=usage_log.id,
            feature_name=usage_log.feature_name,
            user_id=usage_log.user_id,
            duration_seconds=usage_log.duration_seconds,
            timestamp=usage_log.timestamp,
            metadata=usage_log.extra_metadata or {}
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected error in create_feature_usage_log: {type(e).__name__}: {str(e)}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error inesperado al registrar el evento: {str(e)}"
        )
