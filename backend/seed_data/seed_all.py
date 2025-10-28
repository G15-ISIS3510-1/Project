from __future__ import annotations

import os
import sys
import time
import random
from typing import Dict, Any
import requests
import asyncio
from datetime import datetime, timedelta, timezone, time as dtime

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

# NEW: share admin token with utils (so httpx helpers can reuse it)
from .utils import set_admin_token

# -----------------------------
# CONFIG
# -----------------------------
BASE = os.getenv("SEED_BASE_URL", "https://qovo-api-862569067561.us-central1.run.app")
ADMIN_EMAIL = os.getenv("SEED_EMAIL", "admin@example.com")
ADMIN_PASSWORD = os.getenv("SEED_PASSWORD", "supersecret")
ADMIN_ROLE = os.getenv("SEED_ROLE", "host")

TONY_EMAIL = os.getenv("SEED_TONY_EMAIL", "stark@industries.com")
TONY_PASSWORD = os.getenv("SEED_TONY_PASSWORD", "12345678")
TONY_NAME = os.getenv("SEED_TONY_NAME", "Tony Stark")
# renter | host | both — use "both" by default so Tony can do everything in demos
TONY_ROLE = os.getenv("SEED_TONY_ROLE", "both")

# Let Tony book before/without global bookings
SKIP_GLOBAL_BOOKINGS = str(os.getenv("SEED_SKIP_GLOBAL_BOOKINGS", "1")).lower() in ("1", "true", "yes", "y")

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
        print(f"[seed] /auth/me failed: {r.status_code} -> {r.text}")
        return None
    return r.json()

def _register_admin_if_needed() -> None:
    """
    Ensure admin exists and store ADMIN_TOKEN.
    Also tell utils.py about this token so it can use it as fallback auth.
    """
    global ADMIN_TOKEN
    print(f"[seed] ensuring admin user {ADMIN_EMAIL!r} exists at {BASE}")

    ok, payload = _login(ADMIN_EMAIL, ADMIN_PASSWORD)
    if ok and payload and "access_token" in payload:
        ADMIN_TOKEN = payload["access_token"]
        print("[seed] admin already exists; login OK.")
        set_admin_token(ADMIN_TOKEN)
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
            set_admin_token(ADMIN_TOKEN)
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
                set_admin_token(ADMIN_TOKEN)
            return

    if r.status_code == 409:
        print("[seed] server says user already exists; continuing.")
        ok3, payload3 = _login(ADMIN_EMAIL, ADMIN_PASSWORD)
        if ok3 and payload3 and "access_token" in payload3:
            ADMIN_TOKEN = payload3["access_token"]
            set_admin_token(ADMIN_TOKEN)
        return

    print(f"[seed] ERROR registering admin: HTTP {r.status_code} -> {r.text}")
    r.raise_for_status()


# -----------------------------
# TONY STARK HELPERS / SEEDERS
# -----------------------------
def ensure_tony_stark() -> tuple[str, str]:
    """
    Ensure Tony Stark exists and return (tony_token, tony_user_id).
    All further data we create for Tony will use tony_token.
    """
    ok, payload = _login(TONY_EMAIL, TONY_PASSWORD)
    if not ok or not payload or "access_token" not in payload:
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

    me_data = _me(token)
    if not me_data or "user_id" not in me_data:
        raise RuntimeError("Could not fetch Tony's user_id via /auth/me")
    tony_id = me_data["user_id"]
    print(f"[seed] Tony Stark ensured. user_id={tony_id}")
    return token, tony_id


def list_users_admin() -> list[dict]:
    """
    List users using ADMIN_TOKEN.
    Works with both legacy [ {...}, {...} ] responses
    and new paginated { items: [...], total, skip, limit } responses.
    """
    r, ok = _get("/api/users/", token=ADMIN_TOKEN)
    if not ok:
        raise RuntimeError(f"List users failed: {r.status_code} -> {r.text}")

    try:
        data = r.json()
    except Exception:
        return []

    if isinstance(data, dict) and "items" in data and isinstance(data["items"], list):
        return data["items"]
    if isinstance(data, list):
        return data
    return []


def _iso(dt: datetime) -> str:
    """UTC ISO8601, no microseconds."""
    return dt.astimezone(timezone.utc).replace(microsecond=0).isoformat()


def _price_snapshot():
    """Simple pricing snapshot consistent with seed_bookings."""
    daily_price = round(random.uniform(35, 160), 2)
    fees = round(daily_price * 0.15, 2)
    taxes = round(daily_price * 0.08, 2)
    total = round(daily_price + fees + taxes, 2)
    return daily_price, fees, taxes, total


def seed_tony_conversations(tony_token: str, tony_id: str, max_pairs: int = 5):
    """
    Create up to 'max_pairs' direct conversations for Tony with other users
    and send an initial message in each — as Tony.
    """
    all_users = list_users_admin()

    # exclude Tony himself, cap at max_pairs
    others = [u for u in all_users if u.get("user_id") and u["user_id"] != tony_id][:max_pairs]

    print(f"[seed][tony] starting conversations with {len(others)} users")

    for u in others:
        other_id = u["user_id"]

        # create (or ensure) direct conversation
        r, ok = _post(
            "/api/conversations/direct",
            {"other_user_id": other_id},
            token=tony_token,
            expected=(200, 201),
        )
        if not ok:
            print(f"[seed] ensure conversation with {other_id} failed: {r.status_code} -> {r.text}")

        # send first message from Tony
        msg = f"Hey {u.get('name','there')} — Tony here!"
        r2, ok2 = _post(
            "/api/messages",
            {"receiver_id": other_id, "content": msg},
            token=tony_token,
            expected=(200, 201),
        )
        if not ok2:
            print(f"[seed] send message to {other_id} failed: {r2.status_code} -> {r2.text}")
        else:
            print(f"[seed] conversation+message seeded with user {other_id}")


def seed_tony_bookings(tony_token: str, tony_id: str, how_many: int = 2, days_to_try: int = 10):
    """
    Make Tony create bookings on some active vehicles.
    - Tries deterministic 10:00→16:00 UTC windows
    - Iterates day+1 .. day+N until availability accepts
    - Skips vehicles owned by Tony (if any)
    """
    # get active vehicles (list or paginated)
    r, ok = _get("/api/vehicles/active", token=ADMIN_TOKEN)
    if not ok:
        print(f"[seed] list vehicles failed: {r.status_code} -> {r.text}")
        return

    try:
        vehicles_payload = r.json()
    except Exception:
        vehicles_payload = []

    if isinstance(vehicles_payload, dict) and "items" in vehicles_payload and isinstance(vehicles_payload["items"], list):
        vehicles = vehicles_payload["items"]
    elif isinstance(vehicles_payload, list):
        vehicles = vehicles_payload
    else:
        vehicles = []

    print(f"[seed][tony] trying to book {how_many} vehicles")

    successes = 0
    for v in vehicles:
        if successes >= how_many:
            break

        vid = v.get("vehicle_id") or v.get("id")
        if not vid:
            continue

        # fetch detail to learn owner_id/host
        rv, okv = _get(f"/api/vehicles/{vid}", token=tony_token, expected=(200,))
        if not okv:
            print(f"[seed] could not fetch vehicle {vid}: {rv.status_code} -> {rv.text}")
            continue

        try:
            vehicle = rv.json()
        except Exception:
            vehicle = {}

        host_id = vehicle.get("owner_id")
        if not host_id or host_id == tony_id:
            # skip cars owned by Tony or missing owner info
            continue

        # attempt tomorrow..+N with a fixed 6h window inside common availability
        for offset in range(1, days_to_try + 1):
            day = datetime.now(timezone.utc).date() + timedelta(days=offset)
            start = datetime.combine(day, dtime(10, 0, tzinfo=timezone.utc))
            end = datetime.combine(day, dtime(16, 0, tzinfo=timezone.utc))

            # snapshots similar to seed_bookings
            daily_price, fees, taxes, total = _price_snapshot()

            payload = {
                "vehicle_id": vid,
                "renter_id": tony_id,
                "host_id": host_id,
                "insurance_plan_id": None,
                "start_ts": _iso(start),
                "end_ts": _iso(end),

                "daily_price_snapshot": daily_price,
                "insurance_daily_cost_snapshot": None,
                "subtotal": daily_price,
                "fees": fees,
                "taxes": taxes,
                "total": total,
                "currency": "USD",

                # let backend set default status (typically 'pending')
            }

            rb, okb = _post("/api/bookings", payload, token=tony_token, expected=(200, 201))

            if okb:
                print(f"[seed][tony] ✓ booking created for vehicle {vid} on {day} 10:00–16:00Z")
                successes += 1
                break  # next vehicle
            else:
                # if it's the availability business-rule, keep trying other days; otherwise, stop trying this vehicle
                try:
                    detail = rb.json().get("detail", "")
                except Exception:
                    detail = rb.text
                if isinstance(detail, str) and "no hay disponibilidad" in detail.lower():
                    continue  # try next day for this vehicle
                else:
                    print(f"[seed] booking failed for vehicle {vid}: {rb.status_code} -> {rb.text}")
                    break  # move on to next vehicle

    if successes == 0:
        print("[seed][tony] ⚠ no bookings could be created (likely all windows unavailable).")
    else:
        print(f"[seed][tony] bookings created: {successes}")


# -----------------------------
# MAIN ORCHESTRATION
# -----------------------------
def main():
    print(f"[seed] start → BASE={BASE}")
    _register_admin_if_needed()  # populates ADMIN_TOKEN and shares it with utils

    # bulk data
    seed_users(n=int(os.getenv("SEED_USERS_COUNT", "10")))
    seed_vehicles()
    seed_pricing()
    seed_availability(
        days=30,
        past_days=5,
    )
    seed_insurance_plans()
    seed_conversations(
        max_pairs=int(os.getenv("SEED_CONVERSATION_PAIRS", "20"))
    )
    seed_messages(
        messages_per_conversation=int(os.getenv("SEED_MESSAGES_PER_CONVERSATION", "10"))
    )

    # Tony + attached data (do this BEFORE/INSTEAD OF global bookings)
    print("\n[seed] ensuring Tony Stark and attaching sample data...")
    tony_token, tony_id = ensure_tony_stark()
    seed_tony_conversations(
        tony_token,
        tony_id,
        max_pairs=int(os.getenv("SEED_TONY_MAX_CONVERSATIONS", "30")),
    )
    seed_tony_bookings(
        tony_token,
        tony_id,
        how_many=int(os.getenv("SEED_TONY_TOTAL_VEHICLES", "5")),
    )

    # Global bookings (optional)
    if SKIP_GLOBAL_BOOKINGS:
        print("[seed] Skipping global random bookings so Tony can keep availability (SEED_SKIP_GLOBAL_BOOKINGS=1).")
    else:
        seed_bookings(
            per_vehicle=int(os.getenv("SEED_BOOKINGS_PER_VEHICLE", "6"))
        )
        seed_payments(
            max_per_booking=int(os.getenv("SEED_PAYMENTS_MAX_PER_BOOKING", "2"))
        )

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
