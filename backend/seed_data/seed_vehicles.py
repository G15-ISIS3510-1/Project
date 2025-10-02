# ----------------------------
# Archivo: seed_data/seed_vehicles.py
# ----------------------------
from __future__ import annotations

from faker import Faker
import random
from typing import Any, Dict, List

from .utils import login, post_with_auth
from .seed_users import USERS_CREATED

fake = Faker()
VEHICLES_CREATED: List[Dict[str, Any]] = []


def _build_vehicle_payload() -> Dict[str, Any]:
    """
    Construye un payload que cumpla con tu VehicleCreate:
    Requeridos (según tu 422): make, model, year, plate, seats,
    transmission, fuel_type, mileage, status, lat, lng
    """
    transmissions = ["AT", "MT", "CVT", "EV"]
    fuels        = ["gas", "diesel", "hybrid", "ev"]
    statuses     = ["active", "inactive", "pending_review"]

    return {
        "make": random.choice(["Toyota", "Honda", "Ford", "Chevrolet", "Mazda",
                               "Hyundai", "Nissan", "Kia", "Volkswagen"]),
        "model": fake.word().title(),
        "year": random.randint(2016, 2024),
        "plate": fake.unique.bothify(text="???-####").upper(),
        "seats": random.choice([2, 4, 5, 7]),
        "transmission": random.choice(transmissions),
        "fuel_type": random.choice(fuels),
        "mileage": random.randint(5_000, 120_000),
        "status": random.choice(statuses),
        "lat": round(random.uniform(-34.7, 40.7), 6),
        "lng": round(random.uniform(-58.5, -3.7), 6),
    }


def seed_vehicles(count_per_host: int = 1):
    """
    Crea vehículos vía POST /api/vehicles/ para cada usuario host/both.
    Debe ejecutarse después de seed_users (necesita login de hosts).
    """
    global VEHICLES_CREATED
    VEHICLES_CREATED.clear()

    total_attempted = 0
    total_created = 0

    for u in USERS_CREATED:
        if u.get("role") in ("host", "both"):
            token = login(u["email"], u["password"])

            for _ in range(count_per_host):
                total_attempted += 1
                payload = _build_vehicle_payload()

                try:
                    # Importante: usar siempre trailing slash
                    data = post_with_auth("/api/vehicles/", token, payload)
                except Exception as e:
                    print(f"[seed_vehicles] POST failed: {e}")
                    continue

                if not isinstance(data, dict):
                    print(f"[seed_vehicles] respuesta no-dict al crear vehículo: {data!r}")
                    continue

                vehicle_id = data.get("vehicle_id") or data.get("id")
                if not vehicle_id:
                    print(f"[seed_vehicles] respuesta sin vehicle_id: {data!r}")
                    continue

                VEHICLES_CREATED.append({"vehicle_id": vehicle_id, "token": token})
                total_created += 1

    print(f"[seed_vehicles] Vehículos creados: {total_created}/{total_attempted}")
    return VEHICLES_CREATED
