# ----------------------------
# Archivo: seed_data/seed_payments.py
# ----------------------------
import random
import httpx
from .utils import BASE_URL
from .seed_bookings import BOOKINGS_CREATED

PAYMENTS_CREATED = []  # [{"payment_id":"...", "booking_id":"..."}]

def seed_payments(max_per_booking: int = 1):
    """
    Crea pagos con POST /api/payments.
    Reglas del router: el token debe pertenecer al payer (renter).
    El servicio valida que payer == renter de la reserva.
    """
    global PAYMENTS_CREATED
    PAYMENTS_CREATED.clear()

    if not BOOKINGS_CREATED:
        print("[seed_payments] No hay reservas para pagar.")
        return PAYMENTS_CREATED

    with httpx.Client(timeout=15.0) as client:
        for b in BOOKINGS_CREATED:
            for _ in range(max_per_booking):
                amount = round(random.uniform(40, 250), 2)
                payload = {
                    "booking_id": b["booking_id"],
                    "payer_id": b["renter_id"],
                    "amount": amount,
                    "currency": "USD",
                    "status": "captured",     # coincide con enum PaymentStatus del modelo
                    "provider": random.choice(["stripe", "adyen", "manual"]),
                    "provider_ref": None,
                }
                r = client.post(
                    f"{BASE_URL}/api/payments/",
                    json=payload,
                    headers={"Authorization": f"Bearer {b['token_renter']}"},
                )
                if r.status_code in (200, 201):
                    data = r.json()
                    PAYMENTS_CREATED.append(
                        {
                            "payment_id": data.get("payment_id") or data.get("id"),
                            "booking_id": b["booking_id"],
                        }
                    )
                else:
                    print("[seed_payments] Error:", r.status_code, r.text)

    print(f"[seed_payments] Pagos creados: {len(PAYMENTS_CREATED)}")
    return PAYMENTS_CREATED
