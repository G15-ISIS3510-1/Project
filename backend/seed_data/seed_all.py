from __future__ import annotations

import os
import sys
import time
from typing import Dict, Any
import requests

from .seed_users import seed_users
from .seed_vehicles import seed_vehicles
from .seed_availability import seed_availability
from .seed_pricing import seed_pricing
from .seed_conversations import seed_conversations
from .seed_messages import seed_messages
from .seed_bookings import seed_bookings
from .seed_payments import seed_payments
from .seed_insurance_plans import seed_insurance_plans
from .seed_vehicle_ratings import seed_vehicle_ratings
import asyncio

BASE = os.getenv("SEED_BASE_URL", "http://127.0.0.1:8000")
ADMIN_EMAIL = os.getenv("SEED_EMAIL", "admin@example.com")
ADMIN_PASSWORD = os.getenv("SEED_PASSWORD", "supersecret")
ADMIN_ROLE = os.getenv("SEED_ROLE", "host")

def _post(path: str, json: Dict[str, Any], expected=(200, 201), timeout=10):
    url = f"{BASE}{path}"
    r = requests.post(url, json=json, timeout=timeout)
    return r, (r.status_code in expected)

def _login(email: str, password: str):
    r, ok = _post("/api/auth/login", {"email": email, "password": password})
    if not ok:
        return False, None
    try:
        return True, r.json()
    except Exception:
        return True, None

def _register_admin_if_needed() -> None:
    print(f"[seed] ensuring admin user {ADMIN_EMAIL!r} exists at {BASE} ")

    ok, _payload = _login(ADMIN_EMAIL, ADMIN_PASSWORD)
    if ok:
        print("[seed] admin already exists (login ok); skipping registration.")
        return

    body = {
        "name": "Admin",
        "email": ADMIN_EMAIL,
        "phone": "3000000000",
        "password": ADMIN_PASSWORD,
        "role": ADMIN_ROLE,
    }

    r, ok = _post("/api/auth/register", body, expected=(200, 201))
    if ok:
        print("[seed] admin registered successfully.")
        time.sleep(0.5)
        ok2, _ = _login(ADMIN_EMAIL, ADMIN_PASSWORD)
        if ok2:
            print("[seed] admin login verified.")
        else:
            print("[seed] WARNING: login after registration failed (continuing).")
        return

    if r.status_code == 400:
        try:
            detail = r.json().get("detail", "")
        except Exception:
            detail = r.text
        if "ya está registrado" in str(detail).lower() or "already" in str(detail).lower():
            print("[seed] admin already exists (400), continuing.")
            return

    if r.status_code == 409:
        print("[seed] server says user already exists; continuing.")
        return

    print(f"[seed] ERROR registering admin: HTTP {r.status_code} -> {r.text}")
    r.raise_for_status()

def main():
    print("[seed] start")
    _register_admin_if_needed()

    seed_users(n=12)
    seed_vehicles()         # make sure fuel_type values are one of: gas|diesel|hybrid|ev
    seed_pricing()
    seed_availability(days=30, past_days=60)  
    seed_insurance_plans()
    seed_conversations(max_pairs=5)
    seed_messages(messages_per_conversation=3)
    seed_bookings(per_vehicle=4)  
    seed_payments(max_per_booking=1)
    
    print("\n[seed] Creando calificaciones de vehículos...")
    try:
        asyncio.run(seed_vehicle_ratings())
    except Exception as e:
        print(f"[seed] Error al crear calificaciones: {e}")
        print("[seed] Puedes ejecutar 'python seed_data/seed_vehicle_ratings.py' manualmente después")
    
    print("[seed] done")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n[seed] aborted by user")
        sys.exit(130)
