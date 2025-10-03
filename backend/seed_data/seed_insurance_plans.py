# ----------------------------
# Archivo: seed_data/seed_insurance_plans.py
# ----------------------------
from __future__ import annotations

from typing import List, Dict, Any

from .utils import login, post_with_auth, find_path

PLANS_CREATED: List[Dict[str, Any]] = []  # [{"insurance_plan_id": "..."}]


def seed_insurance_plans():
    """
    Crea algunos planes de seguro. Resuelve el path correcto consultando openapi.
    """
    global PLANS_CREATED
    PLANS_CREATED.clear()

    token = login()  # usa las credenciales de SEED_EMAIL/SEED_PASSWORD

    # Descubre el endpoint correcto (guión vs guion_bajo, con/sin slash final)
    plans_path = find_path(
        "/api/insurance_plans/",
        ["/api/insurance-plans/", "/api/insurance_plans", "/api/insurance-plans"]
    )

    plans = [
        {
            "name": "Basic",
            "deductible": 1000.0,
            "daily_cost": 5.0,
            "coverage_summary": "Liability only. High deductible.",
            "active": True,
        },
        {
            "name": "Standard",
            "deductible": 500.0,
            "daily_cost": 10.0,
            "coverage_summary": "Liability + collision.",
            "active": True,
        },
        {
            "name": "Premium",
            "deductible": 250.0,
            "daily_cost": 18.0,
            "coverage_summary": "Full coverage with low deductible.",
            "active": True,
        },
    ]

    created_count = 0
    for p in plans:
        try:
            created = post_with_auth(plans_path, token, p)
        except Exception as e:
            print(f"[seed_insurance] POST failed for {p.get('name')}: {e}")
            continue

        insurance_plan_id = created.get("insurance_plan_id") or created.get("id")
        if not insurance_plan_id:
            print(f"[seed_insurance] respuesta sin insurance_plan_id: {created!r}")
            continue

        PLANS_CREATED.append({"insurance_plan_id": insurance_plan_id})
        created_count += 1

    print(f"[seed_insurance] Planes creados: {created_count}/{len(plans)}")
    return PLANS_CREATED
