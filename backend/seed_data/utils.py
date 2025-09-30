# ----------------------------
# Archivo: seed_data/utils.py
# ----------------------------
import os
import re
import httpx

BASE_URL = os.getenv("SEED_BASE_URL", "http://127.0.0.1:8000")

def clean_phone(raw: str, max_len: int = 15) -> str:
    digits = re.sub(r"\D+", "", raw or "")
    return digits[:max_len] or "0000000000"

def login(email: str, password: str) -> str:
    with httpx.Client(timeout=10.0) as client:
        r = client.post(f"{BASE_URL}/api/auth/login", json={"email": email, "password": password})
        r.raise_for_status()
        data = r.json()
        # soporta "access_token" o "token"
        return data.get("access_token") or data.get("token")

def post_with_auth(endpoint: str, token: str, data: dict) -> dict:
    headers = {"Authorization": f"Bearer {token}"}
    r = httpx.post(f"{BASE_URL}{endpoint}", json=data, headers=headers, follow_redirects=True)
    r.raise_for_status()
    return r.json()

