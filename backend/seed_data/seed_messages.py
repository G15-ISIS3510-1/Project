# ----------------------------
# Archivo: seed_data/seed_messages.py
# ----------------------------
import random
import httpx
from .utils import BASE_URL, login
from .seed_conversations import CONVERSATIONS_CREATED

MESSAGES_CREATED = []  # [{"message_id": "...", "conversation_id": "..."}]

_SAMPLE = [
    "Hola! ¿El coche está disponible para este fin de semana?",
    "Sí, está libre del viernes al domingo.",
    "Perfecto. ¿El precio incluye seguro básico?",
    "Incluye responsabilidad civil. Podemos sumar cobertura adicional.",
    "Vale, me interesa el plan Premium para estar tranquilo.",
]

def seed_messages(messages_per_conversation: int = 3):
    """
    Crea mensajes en cada conversación existente usando POST /api/messages.
    Alterna entre usuario A y B de cada conversación para simular un chat.
    """
    global MESSAGES_CREATED
    MESSAGES_CREATED.clear()

    if not CONVERSATIONS_CREATED:
        print("[seed_messages] No hay conversaciones creadas.")
        return MESSAGES_CREATED

    with httpx.Client(timeout=15.0) as client:
        for conv in CONVERSATIONS_CREATED:
            a_id = conv["user_a_id"]
            b_id = conv["user_b_id"]

            # alterna emisores
            sender_is_a = True
            for i in range(messages_per_conversation):
                content = random.choice(_SAMPLE)
                sender_id = a_id if sender_is_a else b_id
                receiver_id = b_id if sender_is_a else a_id

                # login como sender
                # (necesitamos su email/pwd; si no lo guardaste aquí, puedes guardarlos en CONVERSATIONS_CREATED)
                # Para simplificar: pedimos nuevo login rápido desde USERS_CREATED (lookup)
                # Si no quieres buscar, guarda email/pwd en CONVERSATIONS_CREATED al crearlas.
                # Aquí hacemos un pequeño lookup:
                # (evita import circular; hacemos una búsqueda ligera)
                from .seed_users import USERS_CREATED
                creds = next((u for u in USERS_CREATED if u["user_id"] == sender_id), None)
                if not creds:
                    continue
                token = login(creds["email"], creds["password"])

                payload = {
                    "receiver_id": receiver_id,
                    "content": content,
                    "conversation_id": conv["conversation_id"],
                    "meta": None,
                }

                r = client.post(
                    f"{BASE_URL}/api/messages",
                    json=payload,
                    headers={"Authorization": f"Bearer {token}"},
                )
                if r.status_code in (200, 201):
                    msg = r.json()
                    MESSAGES_CREATED.append(
                        {
                            "message_id": msg.get("message_id") or msg.get("id"),
                            "conversation_id": conv["conversation_id"],
                        }
                    )
                else:
                    print("[seed_messages] Error:", r.status_code, r.text)

                sender_is_a = not sender_is_a

    print(f"[seed_messages] Mensajes creados: {len(MESSAGES_CREATED)}")
    return MESSAGES_CREATED
