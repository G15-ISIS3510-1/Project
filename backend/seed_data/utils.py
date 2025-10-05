# seed_data/utils.py
from __future__ import annotations

import os
import json
import requests
from typing import Any, Dict, Optional, List

# Base URL for hitting your running FastAPI
BASE_URL = os.getenv("SEED_BASE_URL", "http://127.0.0.1:8000").rstrip("/")


def _headers(token: Optional[str] = None) -> Dict[str, str]:
    h = {"Content-Type": "application/json"}
    if token:
        h["Authorization"] = f"Bearer {token}"
    return h


def _raise_with_detail(resp: requests.Response) -> None:
    """Print server response detail (JSON if possible) and then raise for status."""
    try:
        detail = resp.json()
    except Exception:
        detail = resp.text
    print(f"[seed][http] {resp.request.method} {resp.url} -> {resp.status_code} {detail!r}")
    resp.raise_for_status()


def _normalize_path(path: str, ensure_trailing_slash: bool = False) -> str:
    """Make a clean, absolute path under BASE_URL, optionally forcing a trailing slash."""
    url = f"{BASE_URL}/{path.lstrip('/')}"
    if ensure_trailing_slash and not url.endswith("/"):
        url += "/"
    return url


def post_with_auth(path: str, token: str, payload: Dict[str, Any]) -> Dict[str, Any]:
    """
    POST JSON with auth and return parsed JSON (dict).
    Raises with a clear message for any 4xx/5xx and prints server error body.
    """
    url = _normalize_path(path, ensure_trailing_slash=True)
    resp = requests.post(url, headers=_headers(token), data=json.dumps(payload))
    if not resp.ok:
        _raise_with_detail(resp)
    try:
        return resp.json()
    except ValueError:
        # Not JSON — print the body to help debug
        print(f"[seed][http] Non-JSON POST response at {url}: {resp.text!r}")
        raise


def get_with_auth(path: str, token: str) -> Dict[str, Any]:
    """GET JSON with auth and return parsed JSON (dict)."""
    url = _normalize_path(path)
    resp = requests.get(url, headers=_headers(token))
    if not resp.ok:
        _raise_with_detail(resp)
    try:
        return resp.json()
    except ValueError:
        print(f"[seed][http] Non-JSON GET response at {url}: {resp.text!r}")
        raise


def login(email: Optional[str] = None, password: Optional[str] = None) -> str:
    """
    Log in against /api/auth/login, returning the bearer token (access_token/token).
    Reads SEED_EMAIL/SEED_PASSWORD if not provided.
    """
    email = email or os.getenv("SEED_EMAIL")
    password = password or os.getenv("SEED_PASSWORD")
    if not email or not password:
        raise RuntimeError("SEED_EMAIL/SEED_PASSWORD not set and no credentials provided to login()")

    url = f"{BASE_URL}/api/auth/login"
    resp = requests.post(url, headers=_headers(), data=json.dumps({"email": email, "password": password}))
    if not resp.ok:
        _raise_with_detail(resp)

    data = resp.json()
    token = data.get("access_token") or data.get("token")
    if not token:
        raise RuntimeError(f"Login response missing token: {data!r}")
    return token


def clean_phone(value: str) -> str:
    """Strip everything except digits."""
    return "".join(ch for ch in value if ch.isdigit())


def find_path(preferred: str, fallbacks: List[str]) -> str:
    """
    Resolve the correct API path using the app's openapi.json.
    Tries preferred first, then fallbacks. Accepts both with/without trailing slash.
    Returns the first path that exists in the OpenAPI spec; otherwise returns preferred.
    """
    try:
        spec = requests.get(f"{BASE_URL}/openapi.json").json()
        paths = set(spec.get("paths", {}).keys())

        def candidates_for(p: str) -> List[str]:
            p_norm = "/" + p.lstrip("/")
            return list({p_norm, p_norm.rstrip("/"), p_norm.rstrip("/") + "/"})

        for candidate in candidates_for(preferred) + sum(
            [candidates_for(fb) for fb in fallbacks], []
        ):
            if candidate in paths:
                return candidate
    except Exception as e:
        print(f"[seed][openapi] could not load or parse openapi.json: {e}")

    # If nothing matched (or openapi isn't available), fall back to preferred.
    return preferred
