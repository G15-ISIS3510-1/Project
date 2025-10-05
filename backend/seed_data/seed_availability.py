# ----------------------------
# Archivo: seed_data/seed_availability.py
# ----------------------------
from datetime import datetime, timedelta, timezone

from .utils import post_with_auth
from .seed_vehicles import VEHICLES_CREATED

def seed_availability(days: int = 14, past_days: int = 60):
    """
    Crea disponibilidad diaria para cada vehículo vía POST /api/vehicle-availability.
    Forzamos 'available' en la ventana 09:00–21:00 UTC para evitar fallos al sembrar bookings.
    
    Args:
        days: Días hacia el futuro (por defecto 14)
        past_days: Días hacia el pasado para permitir reservas completadas (por defecto 60)
    """
    now = datetime.now(timezone.utc).replace(microsecond=0)

    for v in VEHICLES_CREATED:
        # Crear disponibilidad para días pasados (para bookings completed)
        for i in range(-past_days, days):
            day = (now + timedelta(days=i)).date()

            start = datetime(
                year=day.year, month=day.month, day=day.day,
                hour=9, minute=0, second=0, tzinfo=timezone.utc
            )
            end = datetime(
                year=day.year, month=day.month, day=day.day,
                hour=21, minute=0, second=0, tzinfo=timezone.utc
            )

            payload = {
                "vehicle_id": v["vehicle_id"],
                "start_ts": start.isoformat(),
                "end_ts": end.isoformat(),
                "type": "available",     # <- Forzado para el seed
                "notes": "Seed slot (09–21 UTC, forced available)",
            }
            post_with_auth("/api/vehicle-availability", v["token"], payload)

    print("[seed_availability] Disponibilidad creada.")
