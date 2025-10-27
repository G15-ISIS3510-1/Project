from __future__ import annotations

import os
import sys
import time
from typing import Dict, Any
import requests
import asyncio

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

# -----------------------------
# CONFIG
# -----------------------------
BASE = os.getenv("SEED_BASE_URL", "https://qovo-api-gfa6drobhq-uc.a.run.app")
ADMIN_EMAIL = os.getenv("SEED_EMAIL", "admin@example.com")
ADMIN_PASSWORD = os.getenv("SEED_PASSWORD", "supersecret")
ADMIN_ROLE = os.getenv("SEED_ROLE", "host")

TONY_EMAIL = os.getenv("SEED_TONY_EMAIL", "stark@industries.com")
TONY_PASSWORD = os.getenv("SEED_TONY_PASSWORD", "12345678")
TONY_NAME = os.getenv("SEED_TONY_NAME", "Tony Stark")
# renter | host | both — pick what you need for tests
TONY_ROLE = os.getenv("SEED_TONY_ROLE", "host")

# Filled after admin login
ADMIN_TOKEN: str | None = None


# -----------------------------
# HTTP HELPERS (with Bearer)
# -----------------------------
def _headers(token: str | None = None) -> Dict[str, str]:
    h = {"Content-Type": "application/json"}
    tok = token or ADMIN_TOKEN
    if tok:
        h["Authorization"] = f"Bearer {tok}"
    return h

def _post(path: str, json: Dict[str, Any], expected=(200, 201), timeout=30, token: str | None = None):
    url = f"{BASE}{path}"
    r = requests.post(url, json=json, headers=_headers(token), timeout=timeout)
    print(f"[POST] {url} -> {r.status_code}")
    return r, (r.status_code in expected)

def _get(path: str, params: Dict[str, Any] | None = None, expected=(200,), timeout=30, token: str | None = None):
    url = f"{BASE}{path}"
    r = requests.get(url, params=params, headers=_headers(token), timeout=timeout)
    print(f"[GET ] {r.url} -> {r.status_code}")
    return r, (r.status_code in expected)

def _put(path: str, json: Dict[str, Any], expected=(200,), timeout=30, token: str | None = None):
    url = f"{BASE}{path}"
    r = requests.put(url, json=json, headers=_headers(token), timeout=timeout)
    print(f"[PUT ] {url} -> {r.status_code}")
    return r, (r.status_code in expected)

def _delete(path: str, expected=(200, 204), timeout=30, token: str | None = None):
    url = f"{BASE}{path}"
    r = requests.delete(url, headers=_headers(token), timeout=timeout)
    print(f"[DEL ] {url} -> {r.status_code}")
    return r, (r.status_code in expected)


# -----------------------------
# AUTH HELPERS
# -----------------------------
def _login(email: str, password: str):
    r, ok = _post("/api/auth/login", {"email": email, "password": password}, expected=(200,))
    if not ok:
        return False, None
    try:
        return True, r.json()  # {'access_token': '...'}
    except Exception:
        return True, None

def _register_user(name: str, email: str, phone: str, password: str, role: str) -> bool:
    body = {"name": name, "email": email, "phone": phone, "password": password, "role": role}
    r, ok = _post("/api/auth/register", body, expected=(200, 201))
    if ok:
        return True
    # Idempotent behavior if user already exists
    if r.status_code in (400, 409):
        try:
            detail = r.json().get("detail", "")
        except Exception:
            detail = r.text
        if "ya está registrado" in str(detail).lower() or "already" in str(detail).lower():
            print("[seed] user already exists; continuing.")
            return True
    print(f"[seed] ERROR registering user {email!r}: HTTP {r.status_code} -> {r.text}")
    return False

def _me(token: str):
    r, ok = _get("/api/auth/me", token=token)
    if not ok:
        print(f"[seed] /me failed: {r.status_code} -> {r.text}")
        return None
    return r.json()

def _register_admin_if_needed() -> None:
    """Ensure admin exists and store ADMIN_TOKEN."""
    global ADMIN_TOKEN
    print(f"[seed] ensuring admin user {ADMIN_EMAIL!r} exists at {BASE}")

    ok, payload = _login(ADMIN_EMAIL, ADMIN_PASSWORD)
    if ok and payload and "access_token" in payload:
        ADMIN_TOKEN = payload["access_token"]
        print("[seed] admin already exists; login OK.")
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
        ok2, payload2 = _login(ADMIN_EMAIL, ADMIN_PASSWORD)
        if ok2 and payload2 and "access_token" in payload2:
            ADMIN_TOKEN = payload2["access_token"]
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
            ok3, payload3 = _login(ADMIN_EMAIL, ADMIN_PASSWORD)
            if ok3 and payload3 and "access_token" in payload3:
                ADMIN_TOKEN = payload3["access_token"]
            return

    if r.status_code == 409:
        print("[seed] server says user already exists; continuing.")
        ok3, payload3 = _login(ADMIN_EMAIL, ADMIN_PASSWORD)
        if ok3 and payload3 and "access_token" in payload3:
            ADMIN_TOKEN = payload3["access_token"]
        return

    print(f"[seed] ERROR registering admin: HTTP {r.status_code} -> {r.text}")
    r.raise_for_status()


# -----------------------------
# TONY STARK HELPERS / SEEDERS
# -----------------------------
def ensure_tony_stark() -> tuple[str, str]:
    """
    Ensure Tony Stark exists and return (tony_token, tony_user_id).
    All further data we create for Tony will use tony_token, so it’s attached to him.
    """
    # Try login first
    ok, payload = _login(TONY_EMAIL, TONY_PASSWORD)
    if not ok or not payload or "access_token" not in payload:
        # Create then login
        created = _register_user(TONY_NAME, TONY_EMAIL, "3152403373", TONY_PASSWORD, TONY_ROLE)
        if not created:
            raise RuntimeError("Failed to create Tony Stark")
        time.sleep(0.5)
        ok2, payload2 = _login(TONY_EMAIL, TONY_PASSWORD)
        if not ok2 or not payload2 or "access_token" not in payload2:
            raise RuntimeError("Tony login failed after registration")
        token = payload2["access_token"]
    else:
        token = payload["access_token"]

    me = _me(token)
    if not me or "user_id" not in me:
        raise RuntimeError("Could not fetch Tony's user_id via /auth/me")
    tony_id = me["user_id"]
    print(f"[seed] Tony Stark ensured. user_id={tony_id}")
    return token, tony_id


def list_users_admin() -> list[dict]:
    """List users using ADMIN token (so we can pick conversation targets)."""
    r, ok = _get("/api/users/", token=ADMIN_TOKEN)
    if not ok:
        raise RuntimeError(f"List users failed: {r.status_code} -> {r.text}")
    try:
        data = r.json()
        return data if isinstance(data, list) else []
    except Exception:
        return []


def seed_tony_conversations(tony_token: str, tony_id: str, max_pairs: int = 5):
    """
    Create up to 'max_pairs' direct conversations for Tony with other users,
    and send an initial message in each — **as Tony**.
    """
    others = [u for u in list_users_admin() if u.get("user_id") and u["user_id"] != tony_id][:max_pairs]

    for u in others:
        other_id = u["user_id"]

        # Ensure direct conversation (Tony is the caller)
        r, ok = _post("/api/conversations/direct",
                      {"other_user_id": other_id},
                      token=tony_token,
                      expected=(200, 201))
        if not ok:
            print(f"[seed] ensure conversation with {other_id} failed: {r.status_code} -> {r.text}")

        # First message (Tony is the sender)
        msg = f"Hey {u.get('name','there')} — Tony here!"
        r2, ok2 = _post("/api/messages",
                        {"receiver_id": other_id, "content": msg},
                        token=tony_token,
                        expected=(200, 201))
        if not ok2:
            print(f"[seed] send message to {other_id} failed: {r2.status_code} -> {r2.text}")
        else:
            print(f"[seed] conversation+message seeded with user {other_id}")


# (Optional) skeleton if you want Tony bookings too — fill fields per your /docs schema.
from datetime import datetime, timedelta
def seed_tony_bookings(tony_token: str, how_many: int = 2):
    rv, ok = _get("/api/vehicles/active", token=ADMIN_TOKEN)
    if not ok:
        print(f"[seed] list vehicles failed: {rv.status_code} -> {rv.text}")
        return
    vehicles = rv.json() if isinstance(rv.json(), list) else []
    vehicles = vehicles[:how_many]
    for v in vehicles:
        vid = v.get("vehicle_id") or v.get("id")
        if not vid:
            continue
        start = (datetime.utcnow() + timedelta(days=2)).isoformat() + "Z"
        end   = (datetime.utcnow() + timedelta(days=5)).isoformat() + "Z"
        payload = {
            "vehicle_id": vid,
            "start_date": start,
            "end_date": end,
            # add required fields from your POST /api/bookings schema
        }
        rb, okb = _post("/api/bookings", payload, token=tony_token, expected=(200, 201))
        if not okb:
            print(f"[seed] booking failed for vehicle {vid}: {rb.status_code} -> {rb.text}")
        else:
            print(f"[seed] booking created for vehicle {vid}")


# -----------------------------
# MAIN ORCHESTRATION
# -----------------------------
def main():
    print(f"[seed] start → BASE={BASE}")
    _register_admin_if_needed()  # populates ADMIN_TOKEN

    # Your existing seeds (they hit BASE; if endpoints need auth, add similar helpers in those files)
    seed_users(n=12)
    seed_vehicles()
    seed_pricing()
    seed_availability(days=30, past_days=60)
    seed_insurance_plans()
    seed_conversations(max_pairs=5)
    seed_messages(messages_per_conversation=3)
    seed_bookings(per_vehicle=4)
    seed_payments(max_per_booking=1)

    # Tony + attached data
    print("\n[seed] ensuring Tony Stark and attaching sample data...")
    tony_token, tony_id = ensure_tony_stark()
    seed_tony_conversations(tony_token, tony_id, max_pairs=5)
    # Optional: 
    seed_tony_bookings(tony_token, how_many=2)

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
