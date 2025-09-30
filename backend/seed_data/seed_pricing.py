# ----------------------------
# Archivo: seed_data/seed_pricing.py
# ----------------------------
import random
from .utils import post_with_auth
from .seed_vehicles import VEHICLES_CREATED

def seed_pricing():
    for v in VEHICLES_CREATED:
        price = {
            "vehicle_id": v["vehicle_id"],
            "daily_price": round(random.uniform(30, 200), 2),
            "min_days": 1,
            "currency": "USD",
        }
        post_with_auth("/api/pricing", v["token"], price)
    print("Precios agregados exitosamente.")
