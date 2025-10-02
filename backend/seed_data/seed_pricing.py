# ----------------------------
# Archivo: seed_data/seed_pricing.py
# ----------------------------
import random
from .utils import post_with_auth
from .seed_vehicles import VEHICLES_CREATED

def seed_pricing():
    """
    Crea un registro de Pricing por vehículo vía POST /api/pricing.
    El modelo Pricing soporta: daily_price, min_days, max_days?, currency.
    """
    for v in VEHICLES_CREATED:
        min_days = random.choice([1, 2, 3])
        max_days = random.choice([None, 7, 14, 30])
        price = {
            "vehicle_id": v["vehicle_id"],
            "daily_price": round(random.uniform(30, 200), 2),
            "min_days": min_days,
            # envía max_days solo si no es None (si tu schema lo permite, puedes enviarlo igual)
            **({"max_days": max_days} if max_days else {}),
            "currency": "USD",
        }
        post_with_auth("/api/pricing", v["token"], price)

    print("[seed_pricing] Precios agregados exitosamente.")
