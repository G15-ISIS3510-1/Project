from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.base import get_db
from app.db.models import User
from app.schemas.insurance_plan import InsurancePlanResponse, InsurancePlanCreate, InsurancePlanUpdate
from app.services.insurance_plan_service import InsurancePlanService
from app.routers.users import get_current_user_from_token
from typing import List

router = APIRouter(prefix="/insurance-plans", tags=["insurance-plans"])

@router.get("/", response_model=List[InsurancePlanResponse])
async def get_insurance_plans(
    skip: int = 0,
    limit: int = 100,
    active_only: bool = True,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Get list of insurance plans"""
    insurance_plan_service = InsurancePlanService(db)
    
    if active_only:
        insurance_plans = await insurance_plan_service.get_active_insurance_plans(skip=skip, limit=limit)
    else:
        insurance_plans = await insurance_plan_service.get_insurance_plans(skip=skip, limit=limit)
    
    return insurance_plans

@router.get("/{insurance_plan_id}", response_model=InsurancePlanResponse)
async def get_insurance_plan(
    insurance_plan_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Get a specific insurance plan by ID"""
    insurance_plan_service = InsurancePlanService(db)
    insurance_plan = await insurance_plan_service.get_insurance_plan(insurance_plan_id)
    
    if not insurance_plan:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Insurance plan not found"
        )
    
    return insurance_plan

@router.get("/booking/{booking_id}", response_model=InsurancePlanResponse)
async def get_insurance_plan_by_booking(
    booking_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Get the insurance plan associated with a booking"""
    insurance_plan_service = InsurancePlanService(db)
    
    # Verify that the booking exists
    booking = await insurance_plan_service.get_booking_by_id(booking_id)
    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Booking not found"
        )
    
    # Verify that the current user has access to the booking
    if booking.renter_id != current_user.user_id and booking.host_id != current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have access to this booking"
        )
    
    insurance_plan = await insurance_plan_service.get_insurance_plan_by_id_booking(booking_id)
    
    if not insurance_plan:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="This booking does not have an associated insurance plan"
        )
    
    return insurance_plan

@router.post("/", response_model=InsurancePlanResponse)
async def create_insurance_plan(
    insurance_plan_data: InsurancePlanCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Create a new insurance plan (admin only)"""
    # In a real case, here you would verify if the user is an administrator
    # For now, we allow any authenticated user to create plans
    
    insurance_plan_service = InsurancePlanService(db)
    
    try:
        insurance_plan = await insurance_plan_service.create_insurance_plan(insurance_plan_data)
        return insurance_plan
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.put("/{insurance_plan_id}", response_model=InsurancePlanResponse)
async def update_insurance_plan(
    insurance_plan_id: str,
    insurance_plan_update: InsurancePlanUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Update an insurance plan (admin only)"""
    # In a real case, here you would verify if the user is an administrator
    
    insurance_plan_service = InsurancePlanService(db)
    
    # Verify that the plan exists
    insurance_plan = await insurance_plan_service.get_insurance_plan(insurance_plan_id)
    if not insurance_plan:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Insurance plan not found"
        )
    
    try:
        updated_insurance_plan = await insurance_plan_service.update_insurance_plan(insurance_plan_id, insurance_plan_update)
        return updated_insurance_plan
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.delete("/{insurance_plan_id}")
async def delete_insurance_plan(
    insurance_plan_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Delete an insurance plan (admin only)"""
    # In a real case, here you would verify if the user is an administrator
    
    insurance_plan_service = InsurancePlanService(db)
    
    # Verify that the plan exists
    insurance_plan = await insurance_plan_service.get_insurance_plan(insurance_plan_id)
    if not insurance_plan:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Insurance plan not found"
        )
    
    success = await insurance_plan_service.delete_insurance_plan(insurance_plan_id)
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error deleting insurance plan"
        )
    
    return {"message": "Insurance plan deleted/deactivated successfully"}
