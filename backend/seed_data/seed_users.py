# ----------------------------
# Archivo: seed_data/seed_users.py
# ----------------------------
from __future__ import annotations

import os
import json
import random
import requests
from typing import Any, Dict, List

from faker import Faker

from .utils import BASE_URL, clean_phone

fake = Faker()

USERS_CREATED: List[Dict[str, Any]] = []  # [{"email": ..., "password": ..., "role": ..., "user_id": ...}]


def _register_user(payload: Dict[str, Any]) -> Dict[str, Any]:
    """
    Llama a POST /api/auth/register (público, sin Authorization).
    Devuelve el JSON (dict) o levanta HTTPError con detalle legible.
    """
    url = f"{BASE_URL}/api/auth/register"
    resp = requests.post(url, headers={"Content-Type": "application/json"}, data=json.dumps(payload))
    if not resp.ok:
        # Intenta mostrar el detalle de FastAPI/Pydantic para depurar 422s
        try:
            detail = resp.json()
        except Exception:
            detail = resp.text
        print(f"[seed_users] register -> {resp.status_code} {detail!r}")
        resp.raise_for_status()
    return resp.json()


def seed_users(n: int = 12) -> List[Dict[str, Any]]:
    """
    Crea n usuarios con mezcla de roles (host/renter/both).
    Guarda en USERS_CREATED email/password/role/user_id para semillas posteriores.
    """
    global USERS_CREATED
    USERS_CREATED.clear()

    roles = ["host", "renter", "both"]

    created = 0
    for _ in range(n):
        role = random.choice(roles)
        name = fake.name()
        email = fake.unique.email()

        # Limpia y limita el teléfono (máx ~15 dígitos es típico para E.164 sin '+')
        raw_phone = fake.msisdn() or fake.phone_number()
        phone = clean_phone(raw_phone)[:15] or "3000000000"

        # Usa contraseñas simples pero válidas para pruebas
        password = fake.password(length=10)

        payload = {
            "name": name,
            "email": email,
            "phone": phone,
            "password": password,
            "role": role,  # requerido por tu esquema de registro
        }

        try:
            data = _register_user(payload)
        except requests.HTTPError:
            # Ya se imprimió el detalle arriba; continúa con el siguiente usuario
            continue

        user_id = data.get("user_id") or data.get("id")
        USERS_CREATED.append(
            {
                "email": email,
                "password": password,
                "role": role,
                "user_id": user_id,
            }
        )
        created += 1

    print(f"[seed_users] Usuarios creados: {created}")
    return USERS_CREATED
