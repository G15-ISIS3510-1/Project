from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from contextlib import asynccontextmanager
from app.core.config import settings
from app.routers import auth, users, vehicles, pricing, vehicle_availability
import uvicorn

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print("Iniciando aplicación FastAPI...")
    print(f"Modo debug: {settings.debug}")
    print(f"CORS origins: {settings.cors_origins}")
    yield
    print(" Cerrando aplicación...")

# Crear aplicación FastAPI
app = FastAPI(
    title="Mobile App Backend",
    description="Backend para aplicación móvil de alquiler de vehículos",
    version="1.0.0",
    debug=settings.debug,
    lifespan=lifespan
)

# Middleware de CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.add_middleware(
    TrustedHostMiddleware,
    allowed_hosts=["*"]  
)

app.include_router(auth.router, prefix="/api")
app.include_router(users.router, prefix="/api")
app.include_router(vehicles.router, prefix="/api")
app.include_router(pricing.router, prefix="/api/pricing")
app.include_router(vehicle_availability.router, prefix="/api/vehicle-availability")

# Rutas básicas
@app.get("/")
async def root():
    """Ruta raíz de la API"""
    return {
        "message": "Bienvenido al sistema de activación",
        "version": "1.0.0",
        "docs": "/docs",
        "redoc": "/redoc"
    }

@app.get("/health")
async def health_check():
    """Health check de la API"""
    return {
        "status": "OK",
        "timestamp": "2024-01-01T00:00:00Z",
        "message": "Servidor funcionando correctamente"
    }

@app.get("/api/test-error")
async def test_error():
    """Endpoint de prueba para errores"""
    raise HTTPException(
        status_code=500,
        detail="Este es un error de prueba para verificar el manejo de errores"
    )

@app.get("/api/test-bad-request")
async def test_bad_request():
    """Endpoint de prueba para bad request"""
    raise HTTPException(
        status_code=400,
        detail="Este es un BadRequestException de prueba"
    )

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug,
        log_level="info"
    )
