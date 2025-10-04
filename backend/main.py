# backend/main.py
from contextlib import asynccontextmanager

import uvicorn
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware

from app.core.config import settings
from app.routers import (
    auth,
    users,
    vehicles,
    pricing,
    vehicle_availability,
    messages,
    conversations,
    bookings,
    insurance_plans,
    payments,
    analytics
)
# import the router object from the file app/routers/insurance_plans.py
from app.routers.insurance_plans import router as insurance_plans_router
from app.routers.payments import router as payments_router

# at the top
import os
from urllib.parse import urlparse, urlunparse

def _mask_pw(url: str) -> str:
    try:
        u = urlparse(url)
        if u.password:
            netloc = u.netloc.replace(f":{u.password}@", ":***@")
            return urlunparse((u.scheme, netloc, u.path, u.params, u.query, u.fragment))
    except Exception:
        pass
    return url

@asynccontextmanager
async def lifespan(app: FastAPI):
    print("Iniciando aplicación FastAPI...")
    print(f"Modo debug: {settings.debug}")
    print(f"CORS origins: {settings.cors_origins}")
    # NEW: show where DB URL came from
    env_url = os.getenv("DATABASE_URL")
    eff = env_url or settings.database_url
    print(f"EFFECTIVE DATABASE_URL: {_mask_pw(eff)}")
    yield
    print(" Cerrando aplicación...")

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print("Iniciando aplicación FastAPI...")
    print(f"Modo debug: {settings.debug}")
    print(f"CORS origins: {settings.cors_origins}")
    yield
    # Shutdown
    print(" Cerrando aplicación...")


# Crear aplicación FastAPI
app = FastAPI(
    title="Mobile App Backend",
    description="Backend para aplicación móvil de alquiler de vehículos",
    version="1.0.0",
    debug=settings.debug,
    lifespan=lifespan,
)

# Middleware de CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Trusted hosts (wide-open for local/dev)
app.add_middleware(TrustedHostMiddleware, allowed_hosts=["*"])

# Routers base
app.include_router(auth.router, prefix="/api")
app.include_router(users.router, prefix="/api")
app.include_router(vehicles.router, prefix="/api")

# Pricing (avoid duplicate include)
app.include_router(pricing.router, prefix="/api/pricing")

app.include_router(vehicle_availability.router, prefix="/api/vehicle-availability")
app.include_router(messages.router, prefix="/api/messages")
app.include_router(conversations.router, prefix="/api/conversations")
app.include_router(bookings.router, prefix="/api/bookings")

# Insurance plans endpoints at /api/insurance_plans/...
app.include_router(insurance_plans_router, prefix="/api/insurance_plans")
app.include_router(payments_router, prefix="/api")

#Analytics
app.include_router(analytics.router, prefix="/api/analytics", tags=["analytics"])

# Rutas básicas
@app.get("/")
async def root():
    """Ruta raíz de la API"""
    return {
        "message": "Bienvenido al sistema de activación",
        "version": "1.0.0",
        "docs": "/docs",
        "redoc": "/redoc",
    }


@app.get("/health")
async def health_check():
    """Health check de la API"""
    return {
        "status": "OK",
        "timestamp": "2024-01-01T00:00:00Z",
        "message": "Servidor funcionando correctamente",
    }


@app.get("/api/test-error")
async def test_error():
    """Endpoint de prueba para errores"""
    raise HTTPException(
        status_code=500,
        detail="Este es un error de prueba para verificar el manejo de errores",
    )


@app.get("/api/test-bad-request")
async def test_bad_request():
    """Endpoint de prueba para bad request"""
    raise HTTPException(
        status_code=400,
        detail="Este es un BadRequestException de prueba",
    )


if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug,
        log_level="info",
    )
