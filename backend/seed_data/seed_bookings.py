# ----------------------------
# Archivo: seed_data/seed_bookings.py
# ----------------------------
from datetime import datetime, timedelta, timezone, time
import random
import httpx

from .utils import BASE_URL, login
from .seed_users import USERS_CREATED
from .seed_vehicles import VEHICLES_CREATED
from .seed_insurance_plans import PLANS_CREATED

BOOKINGS_CREATED = []  # [{"booking_id": "...", "renter_id": "...", "host_id": "...", "vehicle_id": "...", "token_renter": "..."}]

def _iso(dt: datetime) -> str:
    # produce ISO with timezone
    return dt.replace(microsecond=0).isoformat()

def seed_bookings(per_vehicle: int = 1):
    """
    Crea reservas con POST /api/bookings.
    Reglas del router:
      - token debe pertenecer al renter (payload.renter_id == current_user).
      - host_id debe ser dueño del vehículo.
      - start_ts < end_ts.
    NOTA: este seed alinea siempre las horas con la disponibilidad 09–21 creada en seed_availability.
    """
    global BOOKINGS_CREATED
    BOOKINGS_CREATED.clear()

    if not VEHICLES_CREATED:
        print("[seed_bookings] No hay vehículos para reservar.")
        return BOOKINGS_CREATED

    renters = [u for u in USERS_CREATED if u["role"] in ("renter", "both")]
    if not renters:
        print("[seed_bookings] No hay usuarios renter/both.")
        return BOOKINGS_CREATED

    with httpx.Client(timeout=20.0) as client:
        for v in VEHICLES_CREATED:
            for _ in range(per_vehicle):
                renter = random.choice(renters)
                renter_token = login(renter["email"], renter["password"])

                # Obtener info del vehículo (para tomar owner_id real)
                rv = client.get(
                    f"{BASE_URL}/api/vehicles/{v['vehicle_id']}",
                    headers={"Authorization": f"Bearer {renter_token}"},
                )
                if rv.status_code != 200:
                    print("[seed_bookings] No pude obtener el vehículo:", rv.status_code, rv.text)
                    continue

                vehicle = rv.json()
                host_id = vehicle["owner_id"]
                if host_id == renter["user_id"]:
                    # evita crear una reserva donde renter == host
                    continue

                # Día objetivo 1–10 días hacia adelante, dentro del rango 09–21
                today_utc = datetime.now(timezone.utc).date()
                day_date = today_utc + timedelta(days=random.randint(1, 6))

                start = datetime.combine(day_date, time(10, 0, tzinfo=timezone.utc))  # 10:00 UTC fijo
                duration_hours = random.choice([4, 6, 8])                              # 14:00 / 16:00 / 18:00
                end = start + timedelta(hours=duration_hours)

                # No permitir pasar de 21:00 UTC
                latest_end = datetime.combine(day_date, time(21, 0, tzinfo=timezone.utc))
                if end > latest_end:
                    end = latest_end

                # snapshots económicos (no depende del endpoint de pricing)
                daily_price = round(random.uniform(35, 160), 2)
                # Al ser dentro del mismo día, días facturables = 1
                days_billable = 1
                ins = random.choice(PLANS_CREATED) if PLANS_CREATED else None
                ins_cost = round(random.uniform(0, 20), 2) if ins else 0.0

                subtotal = round(days_billable * daily_price + days_billable * ins_cost, 2)
                fees = 0.0
                taxes = 0.0
                total = round(subtotal + fees + taxes, 2)

                payload = {
                    "vehicle_id": v["vehicle_id"],
                    "renter_id": renter["user_id"],
                    "host_id": host_id,
                    "insurance_plan_id": ins["insurance_plan_id"] if ins else None,
                    "start_ts": _iso(start),
                    "end_ts": _iso(end),

                    "daily_price_snapshot": daily_price,
                    "insurance_daily_cost_snapshot": ins_cost if ins else None,
                    "subtotal": subtotal,
                    "fees": fees,
                    "taxes": taxes,
                    "total": total,
                    "currency": "USD",

                    "odo_start": None,
                    "odo_end": None,
                    "fuel_start": None,
                    "fuel_end": None,
                    "status": "pending",
                }

                r = client.post(
                    f"{BASE_URL}/api/bookings",
                    json=payload,
                    headers={"Authorization": f"Bearer {renter_token}"},
                )
                if r.status_code in (200, 201):
                    b = r.json()
                    BOOKINGS_CREATED.append(
                        {
                            "booking_id": b.get("booking_id") or b.get("id"),
                            "vehicle_id": v["vehicle_id"],
                            "host_id": host_id,
                            "renter_id": renter["user_id"],
                            "token_renter": renter_token,
                        }
                    )
                else:
                    print("[seed_bookings] Error:", r.status_code, r.text)

    print(f"[seed_bookings] Reservas creadas: {len(BOOKINGS_CREATED)}")
    return BOOKINGS_CREATED
