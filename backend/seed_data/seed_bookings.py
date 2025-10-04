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
    """Produce ISO string with timezone."""
    return dt.replace(microsecond=0).isoformat()

def _get_random_odometer_fuel():
    """Generate realistic odometer and fuel level values."""
    odo_start = random.randint(10000, 150000)
    trip_distance = random.randint(20, 300)
    odo_end = odo_start + trip_distance
    
    fuel_start = random.choice([25, 50, 75, 100])
    fuel_consumed = random.randint(10, 50)
    fuel_end = max(0, fuel_start - fuel_consumed)
    
    return odo_start, odo_end, fuel_start, fuel_end

def seed_bookings(per_vehicle: int = 1, include_cancelled: bool = True, include_multi_day: bool = True):
    """
    Crea reservas con POST /api/bookings.
    
    Args:
        per_vehicle: Número de reservas por vehículo
        include_cancelled: Si True, incluye algunas reservas canceladas
        include_multi_day: Si True, incluye reservas de múltiples días
    
    Reglas del router:
      - token debe pertenecer al renter (payload.renter_id == current_user).
      - host_id debe ser dueño del vehículo.
      - start_ts < end_ts.
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

                # Obtener info del vehículo
                rv = client.get(
                    f"{BASE_URL}/api/vehicles/{v['vehicle_id']}",
                    headers={"Authorization": f"Bearer {renter_token}"},
                )
                if rv.status_code != 200:
                    print(f"[seed_bookings] No pude obtener el vehículo {v['vehicle_id']}: {rv.status_code}")
                    continue

                vehicle = rv.json()
                host_id = vehicle["owner_id"]
                
                # Evitar que renter == host
                if host_id == renter["user_id"]:
                    continue

                # Determinar tipo de reserva
                today_utc = datetime.now(timezone.utc).date()
                booking_type = random.choices(
                    ["completed_past", "pending_future", "active_today", "cancelled"],
                    weights=[50, 25, 15, 10 if include_cancelled else 0]
                )[0]

                # Configurar fechas según tipo de reserva
                if booking_type == "completed_past":
                    # Reservas completadas en el pasado (7-60 días atrás)
                    day_date = today_utc - timedelta(days=random.randint(7, 60))
                    status = "completed"
                elif booking_type == "pending_future":
                    # Reservas pendientes en el futuro (1-30 días adelante)
                    day_date = today_utc + timedelta(days=random.randint(1, 30))
                    status = "pending"
                elif booking_type == "active_today":
                    # Reservas activas (hoy o ayer)
                    day_date = today_utc - timedelta(days=random.choice([0, 1]))
                    status = random.choice(["active", "pending"])
                else:  # cancelled
                    # Reservas canceladas (pueden ser pasadas o futuras)
                    day_date = today_utc + timedelta(days=random.randint(-30, 30))
                    status = "cancelled"

                # Determinar duración (reducido multi-día para evitar conflictos)
                if include_multi_day and random.random() < 0.15:
                    # Solo 15% reservas multi-día (2-3 días) para reducir errores
                    duration_days = random.randint(2, 3)
                    start = datetime.combine(day_date, time(10, 0, tzinfo=timezone.utc))
                    end = datetime.combine(
                        day_date + timedelta(days=duration_days),
                        time(18, 0, tzinfo=timezone.utc)
                    )
                    days_billable = duration_days
                else:
                    # 85% reservas de un solo día (4-8 horas) - más confiable
                    start = datetime.combine(day_date, time(10, 0, tzinfo=timezone.utc))
                    duration_hours = random.choice([4, 6, 8])
                    end = start + timedelta(hours=duration_hours)
                    days_billable = 1

                    # No permitir pasar de 21:00 UTC
                    latest_end = datetime.combine(day_date, time(21, 0, tzinfo=timezone.utc))
                    if end > latest_end:
                        end = latest_end

                # Snapshots económicos
                daily_price = round(random.uniform(35, 160), 2)
                ins = random.choice(PLANS_CREATED) if PLANS_CREATED and random.random() < 0.7 else None
                ins_cost = round(random.uniform(5, 20), 2) if ins else 0.0

                subtotal = round(days_billable * daily_price + days_billable * ins_cost, 2)
                fees = round(subtotal * 0.15, 2)  # 15% service fee
                taxes = round(subtotal * 0.08, 2)  # 8% tax
                total = round(subtotal + fees + taxes, 2)

                # Odometer y fuel solo para completed
                odo_start, odo_end, fuel_start, fuel_end = None, None, None, None
                if status == "completed":
                    odo_start, odo_end, fuel_start, fuel_end = _get_random_odometer_fuel()

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

                    "odo_start": odo_start,
                    "odo_end": odo_end,
                    "fuel_start": fuel_start,
                    "fuel_end": fuel_end,
                    "status": status,
                }

                r = client.post(
                    f"{BASE_URL}/api/bookings",
                    json=payload,
                    headers={"Authorization": f"Bearer {renter_token}"},
                )
                
                if r.status_code in (200, 201):
                    b = r.json()
                    booking_info = {
                        "booking_id": b.get("booking_id") or b.get("id"),
                        "vehicle_id": v["vehicle_id"],
                        "host_id": host_id,
                        "renter_id": renter["user_id"],
                        "token_renter": renter_token,
                        "status": status,
                        "start_ts": _iso(start),
                        "end_ts": _iso(end),
                        "total": total,
                    }
                    BOOKINGS_CREATED.append(booking_info)
                    print(f"[seed_bookings] ✓ Reserva {status} creada: {booking_info['booking_id']}")
                else:
                    print(f"[seed_bookings] ✗ Error creando reserva: {r.status_code} - {r.text}")

    print(f"\n[seed_bookings] Resumen:")
    print(f"  Total reservas creadas: {len(BOOKINGS_CREATED)}")
    
    # Estadísticas por estado
    status_counts = {}
    for b in BOOKINGS_CREATED:
        status = b.get("status", "unknown")
        status_counts[status] = status_counts.get(status, 0) + 1
    
    for status, count in sorted(status_counts.items()):
        print(f"  - {status}: {count}")
    
    return BOOKINGS_CREATED


def get_bookings_by_status(status: str):
    """Obtiene todas las reservas con un estado específico."""
    return [b for b in BOOKINGS_CREATED if b.get("status") == status]


def get_bookings_by_vehicle(vehicle_id: str):
    """Obtiene todas las reservas de un vehículo específico."""
    return [b for b in BOOKINGS_CREATED if b["vehicle_id"] == vehicle_id]


def get_bookings_by_renter(renter_id: str):
    """Obtiene todas las reservas de un renter específico."""
    return [b for b in BOOKINGS_CREATED if b["renter_id"] == renter_id]


def get_random_booking(status: str = None):
    """Obtiene una reserva aleatoria, opcionalmente filtrada por estado."""
    if status:
        bookings = get_bookings_by_status(status)
    else:
        bookings = BOOKINGS_CREATED
    
    return random.choice(bookings) if bookings else None
