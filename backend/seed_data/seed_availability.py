# ----------------------------
# Archivo: seed_data/seed_availability.py
# ----------------------------
from datetime import datetime, timedelta, timezone
from .utils import post_with_auth
from .seed_vehicles import VEHICLES_CREATED

def seed_availability(days: int = 7):
    now = datetime.now(timezone.utc).replace(microsecond=0)
    for v in VEHICLES_CREATED:
        for i in range(days):
            start = now + timedelta(days=i, hours=9)   # 09:00
            end   = now + timedelta(days=i, hours=21)  # 21:00
            avail = {
                "vehicle_id": v["vehicle_id"],
                "start_ts": start.isoformat(),
                "end_ts": end.isoformat(),
                "type": "available",
                "notes": "Seed",
            }
            post_with_auth("/api/vehicle-availability", v["token"], avail)
    print("Disponibilidad creada.")
