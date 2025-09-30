# ----------------------------
# Archivo: seed_data/seed_users.py
# ----------------------------
from faker import Faker
import random
import string
import httpx
from .utils import BASE_URL, clean_phone

fake = Faker()
USER_ROLES = ["renter", "host", "both"]
USERS_CREATED = []

def _password(n: int = 10) -> str:
    # >= 8 chars y << 72 bytes (bcrypt)
    alphabet = string.ascii_letters + string.digits
    return "".join(random.choice(alphabet) for _ in range(n))

def seed_users(n: int = 10):
    global USERS_CREATED
    USERS_CREATED.clear()

    with httpx.Client(timeout=10.0) as client:
        for _ in range(n):
            role = random.choice(USER_ROLES)
            pwd = _password(10)
            payload = {
                "name": fake.name(),                 # tu API usa "name"
                "email": fake.unique.email(),
                "password": pwd,                     # >= 8
                "phone": clean_phone(fake.phone_number(), 15),
                "role": role,
            }
            r = client.post(f"{BASE_URL}/api/auth/register", json=payload)

            # Acepta 200 o 201 como éxito
            if r.status_code in (200, 201):
                data = r.json()
                USERS_CREATED.append({
                    "email": payload["email"],
                    "password": pwd,
                    "role": role,
                    "user_id": data.get("user_id") or data.get("id"),
                })
            else:
                print(f"Error creando usuario: {r.status_code} -> {r.text}")

    print(f"Usuarios creados: {len(USERS_CREATED)}")
    return USERS_CREATED

if __name__ == "__main__":
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument("--n", type=int, default=10)
    args = p.parse_args()
    seed_users(n=args.n)
    print("Usuarios creados exitosamente.")
