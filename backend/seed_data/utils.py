# seed_data/utils.py
from __future__ import annotations

import os
import json
from typing import Any, Dict, Optional, List
import requests

# -------------------------------------------------
# Which collection endpoints in your API are defined
# at "/" under their router (i.e. they really live at
# /api/foo/ and will 307 if you call /api/foo)
# -------------------------------------------------
_COLLECTION_BASE_PATHS = {
    "/api/users",
    "/api/vehicles",
    "/api/vehicle-availability",
    "/api/pricing",
    "/api/bookings",
    "/api/conversations",
    "/api/messages",
    "/api/payments",
    "/api/insurance-plans",
}

# -------------------------------------------------
# Base URL for hitting the running FastAPI/Cloud Run
# -------------------------------------------------
BASE_URL = os.getenv("SEED_BASE_URL", "http://127.0.0.1:8000").rstrip("/")

# cache for admin token that we can reuse everywhere
_ADMIN_TOKEN_CACHE: Optional[str] = os.getenv("SEED_ADMIN_TOKEN")


def set_admin_token(token: Optional[str]) -> None:
    """
    seed_all.py calls this after logging in as admin.
    That lets all other seed steps call post_with_auth/get_with_auth
    without manually passing a token every time.
    """
    global _ADMIN_TOKEN_CACHE
    if token:
        _ADMIN_TOKEN_CACHE = token


def _raise_with_detail(resp: requests.Response) -> None:
    """
    Print server response (try JSON first) and then raise.
    Helps you see {"detail":"Token requerido"} and status codes.
    """
    try:
        detail = resp.json()
    except Exception:
        detail = resp.text
    print(f"[seed][http] {resp.request.method} {resp.url} -> {resp.status_code} {detail!r}")
    resp.raise_for_status()


def _normalize_path(path: str, ensure_trailing_slash: bool = False) -> str:
    """
    Build an absolute URL under BASE_URL.
    If ensure_trailing_slash is True and the URL doesn't end with '/',
    append '/' so we don't trigger FastAPI's automatic 307 redirect.
    """
    url = f"{BASE_URL}/{path.lstrip('/')}"
    if ensure_trailing_slash and not url.endswith("/"):
        url += "/"
    return url


def _login_raw(email: str, password: str) -> str:
    """
    Log into /api/auth/login and return the bearer token.
    Used for the admin fallback.
    """
    url = f"{BASE_URL}/api/auth/login"
    resp = requests.post(
        url,
        headers={"Content-Type": "application/json"},
        json={"email": email, "password": password},
        timeout=30,
    )
    if not resp.ok:
        _raise_with_detail(resp)

    data = resp.json()
    token = data.get("access_token") or data.get("token")
    if not token:
        raise RuntimeError(f"[seed][auth] Login response missing token: {data!r}")
    return token


def _get_admin_token() -> Optional[str]:
    """
    Return a bearer token we can safely use as fallback auth.

    Priority:
    1. If seed_all already gave us one via set_admin_token(), use that.
    2. Otherwise, try to log in using SEED_EMAIL / SEED_PASSWORD.
    3. Otherwise, None (unauthenticated).
    """
    global _ADMIN_TOKEN_CACHE
    if _ADMIN_TOKEN_CACHE:
        return _ADMIN_TOKEN_CACHE

    admin_email = os.getenv("SEED_EMAIL")
    admin_password = os.getenv("SEED_PASSWORD")
    if not admin_email or not admin_password:
        return None

    try:
        _ADMIN_TOKEN_CACHE = _login_raw(admin_email, admin_password)
        return _ADMIN_TOKEN_CACHE
    except Exception as e:
        print(f"[seed][auth] WARNING: could not fetch admin token fallback: {e}")
        return None


def _headers(token: Optional[str] = None) -> Dict[str, str]:
    """
    Always send Content-Type: application/json.
    If caller passes a user token (host/renter token), use that.
    Otherwise fall back to the shared admin token.
    """
    effective_token = token or _get_admin_token()
    h: Dict[str, str] = {"Content-Type": "application/json"}
    if effective_token:
        h["Authorization"] = f"Bearer {effective_token}"
    return h


def post_with_auth(path: str, token: Optional[str], payload: Dict[str, Any]) -> Any:
    """
    Authenticated POST.
    We *force* a trailing slash on collection endpoints to avoid FastAPI's 307 redirect,
    because that redirect tends to drop Authorization in Cloud Run.
    """
    force_slash = path.rstrip("/") in _COLLECTION_BASE_PATHS
    url = _normalize_path(path, ensure_trailing_slash=force_slash)

    resp = requests.post(
        url,
        headers=_headers(token),
        json=payload,
        timeout=60,
        allow_redirects=False,  # do not let POST turn into a redirect w/o auth
    )

    if not resp.ok:
        _raise_with_detail(resp)

    try:
        return resp.json()
    except ValueError:
        print(f"[seed][http] Non-JSON POST response at {url}: {resp.text!r}")
        raise


def get_with_auth(path: str, token: Optional[str]) -> Any:
    """
    Authenticated GET.

    For *collection root* GETs like /api/pricing we ALSO force the slash
    (same reason: avoid redirect stripping Authorization).
    For deeper paths like /api/vehicles/active or /api/vehicles/{id},
    we skip forcing the slash so we don't get a redirect the OTHER way.
    """
    force_slash = path.rstrip("/") in _COLLECTION_BASE_PATHS
    url = _normalize_path(path, ensure_trailing_slash=force_slash)

    resp = requests.get(
        url,
        headers=_headers(token),
        timeout=30,
        allow_redirects=not force_slash,  # follow redirects normally for non-root GETs
    )

    if not resp.ok:
        _raise_with_detail(resp)

    try:
        return resp.json()
    except ValueError:
        print(f"[seed][http] Non-JSON GET response at {url}: {resp.text!r}")
        raise


def login(email: Optional[str] = None, password: Optional[str] = None) -> str:
    """
    Convenience login for a specific user (like each vehicle's owner).
    Returns that user's JWT so we can act as them.
    """
    email = email or os.getenv("SEED_EMAIL")
    password = password or os.getenv("SEED_PASSWORD")
    if not email or not password:
        raise RuntimeError("SEED_EMAIL/SEED_PASSWORD not set and no credentials provided to login()")

    url = f"{BASE_URL}/api/auth/login"
    resp = requests.post(
        url,
        headers={"Content-Type": "application/json"},
        json={"email": email, "password": password},
        timeout=30,
    )
    if not resp.ok:
        _raise_with_detail(resp)

    data = resp.json()
    token = data.get("access_token") or data.get("token")
    if not token:
        raise RuntimeError(f"[seed][auth] Login response missing token: {data!r}")
    return token


def clean_phone(value: str) -> str:
    """Keep only digits from a phone number string."""
    return "".join(ch for ch in value if ch.isdigit())


def find_path(preferred: str, fallbacks: List[str]) -> str:
    """
    Tries to detect which endpoint path actually exists right now by reading openapi.json.
    This lets the seeder adapt if you rename something like /api/vehicles/active-with-pricing.
    """
    try:
        spec = requests.get(f"{BASE_URL}/openapi.json", timeout=10).json()
        paths = set(spec.get("paths", {}).keys())

        def variants(p: str) -> List[str]:
            p_norm = "/" + p.lstrip("/")
            return list({p_norm, p_norm.rstrip("/"), p_norm.rstrip("/") + "/"})

        candidates: List[str] = []
        candidates.extend(variants(preferred))
        for fb in fallbacks:
            candidates.extend(variants(fb))

        for cand in candidates:
            if cand in paths:
                return cand
    except Exception as e:
        print(f"[seed][openapi] could not load or parse openapi.json: {e}")

    return preferred
