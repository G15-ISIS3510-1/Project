# ----------------------------
# Archivo: seed_data/seed_conversations.py
# ----------------------------
import random
import httpx
from .utils import BASE_URL, login
from .seed_users import USERS_CREATED

CONVERSATIONS_CREATED = []  # [{"conversation_id": "...", "user_a_id": "...", "user_b_id": "..."}]

def seed_conversations(max_pairs: int = 5):
    """
    Crea conversaciones directas 1:1 usando POST /api/conversations/direct
    El endpoint asegura la unicidad de la pareja (devuelve existente si ya hay).
    Se autentica con el usuario 'A' de cada par.
    """
    global CONVERSATIONS_CREATED
    CONVERSATIONS_CREATED.clear()

    # Toma pares no repetidos de usuarios distintos
    candidates = [u for u in USERS_CREATED]
    random.shuffle(candidates)
    pairs = []
    for i in range(0, min(len(candidates) - 1, max_pairs * 2), 2):
        a = candidates[i]
        b = candidates[i + 1]
        if a["user_id"] != b["user_id"]:
            pairs.append((a, b))
        if len(pairs) >= max_pairs:
            break

    with httpx.Client(timeout=15.0) as client:
        for a, b in pairs:
            # login como A (user actual)
            token_a = login(a["email"], a["password"])
            payload = {"other_user_id": b["user_id"]}
            r = client.post(
                f"{BASE_URL}/api/conversations/direct",
                json=payload,
                headers={"Authorization": f"Bearer {token_a}"},
            )
            if r.status_code in (200, 201):
                conv = r.json()
                CONVERSATIONS_CREATED.append(
                    {
                        "conversation_id": conv.get("conversation_id") or conv.get("id"),
                        "user_a_id": a["user_id"],
                        "user_b_id": b["user_id"],
                    }
                )
            else:
                print("[seed_conversations] Error:", r.status_code, r.text)

    print(f"[seed_conversations] Conversaciones creadas: {len(CONVERSATIONS_CREATED)}")
    return CONVERSATIONS_CREATED
