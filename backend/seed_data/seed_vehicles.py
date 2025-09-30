# ----------------------------
# Archivo: seed_data/seed_vehicles.py
# ----------------------------
from faker import Faker
import random
from .utils import login, post_with_auth
from .seed_users import USERS_CREATED

fake = Faker()
VEHICLES_CREATED = []

def seed_vehicles():
    global VEHICLES_CREATED
    VEHICLES_CREATED.clear()

    # Valores compatibles con tu modelo Vehicle:
    transmissions = ["AT", "MT", "CVT", "EV"]
    fuels = ["gasoline", "diesel", "hybrid", "ev"]

    for u in USERS_CREATED:
        if u["role"] in ("host", "both"):
            token = login(u["email"], u["password"])
            data = {
                "make": fake.company(),
                "model": fake.word(),
                "year": random.randint(2015, 2024),
                "plate": fake.unique.bothify(text="???-####").upper(),  # coincide con columna 'plate'
                "seats": random.choice([2, 4, 5, 7]),
                "transmission": random.choice(transmissions),
                "fuel_type": random.choice(fuels),
                "mileage": random.randint(5_000, 120_000),
                "status": "active",
                "lat": round(random.uniform(-34.7, 40.7), 6),
                "lng": round(random.uniform(-58.5, -3.7), 6),
            }
            # ojo con la ruta: sin slash final suele ser más seguro
            vehicle = post_with_auth("/api/vehicles", token, data)
            VEHICLES_CREATED.append({
                "vehicle_id": vehicle.get("vehicle_id") or vehicle.get("id"),
                "token": token,
            })

    print(f"Vehículos creados: {len(VEHICLES_CREATED)}")
    return VEHICLES_CREATED
