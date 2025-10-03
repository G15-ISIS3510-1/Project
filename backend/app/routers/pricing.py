from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List

from app.db.base import get_db
from app.db.models import User, Vehicle
from app.schemas.pricing import PricingResponse, PricingCreate, PricingUpdate, SuggestPriceRequest, SuggestPriceResponse
from app.services.pricing_services import PricingService
from app.routers.users import get_current_user_from_token
from app.services.vehicle_service import VehicleService
from app.services.ai_pricing import AIPricingService

router = APIRouter(tags=["pricing"])

@router.get("/", response_model=List[PricingResponse])
async def list_pricings(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    pricing_service = PricingService(db)
    pricings = await pricing_service.get_pricings(skip=skip, limit=limit)
    return pricings

@router.get("/{pricing_id}", response_model=PricingResponse)
async def get_pricing(
    pricing_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    pricing_service = PricingService(db)
    pricing = await pricing_service.get_pricing_by_id(pricing_id)
    if not pricing:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Pricing no encontrado")
    return pricing

@router.get("/vehicle/{vehicle_id}", response_model=PricingResponse)
async def get_pricing_by_vehicle(vehicle_id: str, db: AsyncSession = Depends(get_db)):
    svc = PricingService(db)
    pricing = await svc.get_pricing_by_vehicle_id(vehicle_id)
    if not pricing:
        raise HTTPException(status_code=404, detail="Pricing not found")
    return pricing

@router.post("/", response_model=PricingResponse)
async def create_pricing(
    pricing_data: PricingCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    pricing_service = PricingService(db)
    # Verificar que el vehículo pertenece al usuario actual
    result = await db.execute(select(Vehicle).where(Vehicle.vehicle_id == pricing_data.vehicle_id))
    vehicle = result.scalar_one_or_none()
    if not vehicle:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Vehículo no encontrado")
    if vehicle.owner_id != current_user.user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Solo puedes crear pricing para tus propios vehículos")
    try:
        pricing = await pricing_service.create_pricing(pricing_data, pricing_data.vehicle_id)
        return pricing
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))

@router.put("/{pricing_id}", response_model=PricingResponse)
async def update_pricing(
    pricing_id: str,
    pricing_update: PricingUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    pricing_service = PricingService(db)
    # Verificar propiedad del vehículo asociado
    pricing = await pricing_service.get_pricing_by_id(pricing_id)
    if not pricing:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Pricing no encontrado")
    result = await db.execute(select(Vehicle).where(Vehicle.vehicle_id == pricing.vehicle_id))
    vehicle = result.scalar_one_or_none()
    if not vehicle or vehicle.owner_id != current_user.user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="No autorizado para modificar este pricing")
    updated = await pricing_service.update_pricing(pricing_id, pricing_update)
    return updated

@router.put("/vehicle/{vehicle_id}", response_model=PricingResponse)
async def update_pricing_by_vehicle(
    vehicle_id: str,
    pricing_update: PricingUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    pricing_service = PricingService(db)
    result = await db.execute(select(Vehicle).where(Vehicle.vehicle_id == vehicle_id))
    vehicle = result.scalar_one_or_none()
    if not vehicle:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Vehículo no encontrado")
    if vehicle.owner_id != current_user.user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="No autorizado para modificar este pricing")
    updated = await pricing_service.update_pricing_by_vehicle_id(vehicle_id, pricing_update)
    if not updated:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Pricing no encontrado para el vehículo")
    return updated

@router.delete("/{pricing_id}")
async def delete_pricing(
    pricing_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    pricing_service = PricingService(db)
    pricing = await pricing_service.get_pricing_by_id(pricing_id)
    if not pricing:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Pricing no encontrado")
    result = await db.execute(select(Vehicle).where(Vehicle.vehicle_id == pricing.vehicle_id))
    vehicle = result.scalar_one_or_none()
    if not vehicle or vehicle.owner_id != current_user.user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="No autorizado para eliminar este pricing")
    success = await pricing_service.delete_pricing(pricing_id)
    if not success:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Error al eliminar el pricing")
    return {"message": "Pricing eliminado correctamente"}

@router.delete("/vehicle/{vehicle_id}")
async def delete_pricing_by_vehicle(
    vehicle_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    pricing_service = PricingService(db)
    result = await db.execute(select(Vehicle).where(Vehicle.vehicle_id == vehicle_id))
    vehicle = result.scalar_one_or_none()
    if not vehicle:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Vehículo no encontrado")
    if vehicle.owner_id != current_user.user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="No autorizado para eliminar este pricing")
    success = await pricing_service.delete_pricing_by_vehicle_id(vehicle_id)
    if not success:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Pricing no encontrado para el vehículo")
    return {"message": "Pricing eliminado correctamente"}

@router.post("/suggest", response_model=SuggestPriceResponse)
async def suggest_price(
    body: SuggestPriceRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    # 1) Trae vehículos del usuario
    vs = VehicleService(db)
    my_cars = await vs.get_vehicles_by_owner(current_user.user_id)

    # 2) Estructura histórico (si tienes precios en otra tabla, inclúyelos)
    #    Aquí asumimos que el precio puede estar en otra entidad; si no lo tienes, omite.
    user_vehicles_payload = []
    for v in my_cars:
        user_vehicles_payload.append({
            "vehicle_id": v.vehicle_id,
            "make": v.make,
            "model": v.model,
            "year": v.year,
            "transmission": v.transmission,
            "fuel_type": v.fuel_type,
            "seats": v.seats,
            "mileage": v.mileage,
            "lat": v.lat, "lng": v.lng,
            # "daily_price": ...  # si lo puedes obtener de tu tabla Pricing, colócalo aquí
        })

    # 3) Llama al modelo
    ai = AIPricingService()
    result = await ai.suggest(
        user_vehicles=user_vehicles_payload,
        form=body.dict(exclude_none=True),
        currency="USD",  # o saca de preferencias del usuario
    )

    # 4) Valida
    price = result.get("suggested_price")
    if price is None:
        raise HTTPException(status_code=500, detail="No se pudo generar sugerencia de precio")

    return SuggestPriceResponse(suggested_price=float(price), reasoning=result.get("reasoning"))
