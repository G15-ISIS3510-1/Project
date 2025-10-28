# seed_data/seed_pricing.py
# ----------------------------
import random
from .utils import post_with_auth
from .seed_vehicles import VEHICLES_CREATED

def seed_pricing():
    """
    Create one Pricing row per vehicle via POST /api/pricing.

    Each Pricing includes:
      - vehicle_id
      - daily_price
      - min_days
      - (optionally) max_days
      - currency
    """

    for v in VEHICLES_CREATED:
        # v comes from seed_vehicles; it looks like:
        # {
        #   "vehicle_id": "...",
        #   "owner_id": "...",
        #   "token": "<owner's bearer token>"
        # }

        min_days = random.choice([1, 2, 3])
        max_days = random.choice([None, 7, 14, 30])

        body = {
            "vehicle_id": v["vehicle_id"],
            "daily_price": round(random.uniform(30, 200), 2),
            "min_days": min_days,
            # only include max_days if it's not None
            **({"max_days": max_days} if max_days else {}),
            "currency": "USD",
        }

        # this hits /api/pricing/ with Authorization: Bearer <owner token>
        post_with_auth("/api/pricing", v["token"], body)

    print("[seed_pricing] Precios agregados exitosamente.")
