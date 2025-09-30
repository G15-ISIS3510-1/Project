# ----------------------------
# Archivo: seed_data/seed_all.py
# ----------------------------
from .seed_users import seed_users
from .seed_vehicles import seed_vehicles
from .seed_pricing import seed_pricing
from .seed_availability import seed_availability

def run(n_users: int = 10):
    seed_users(n=n_users)
    seed_vehicles()
    seed_pricing()
    seed_availability()
    print("Todos los datos de prueba han sido generados exitosamente.")

if __name__ == "__main__":
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument("--n", type=int, default=10)
    args = p.parse_args()
    run(n_users=args.n)
    print("Datos de prueba creados exitosamente.")