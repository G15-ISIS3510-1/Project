from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.base import get_db
from app.db.models import User
from app.schemas.payment import PaymentResponse, PaymentCreate, PaymentUpdate
from app.services.payment_service import PaymentService
from app.routers.users import get_current_user_from_token
from typing import List

router = APIRouter(prefix="/payments", tags=["payments"])

@router.get("/", response_model=List[PaymentResponse])
async def get_payments(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Get list of payments"""
    payment_service = PaymentService(db)
    payments = await payment_service.get_payments(skip=skip, limit=limit)
    return payments

@router.get("/{payment_id}", response_model=PaymentResponse)
async def get_payment(
    payment_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Get a specific payment by ID"""
    payment_service = PaymentService(db)
    payment = await payment_service.get_payment(payment_id)
    
    if not payment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Payment not found"
        )
    
    # Verify that the current user has access to the payment
    if payment.payer_id != current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have access to this payment"
        )
    
    return payment

@router.get("/user/{user_id}", response_model=List[PaymentResponse])
async def get_payments_by_user(
    user_id: str,
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Get payments for a specific user"""
    # Verify that the current user is querying their own payments
    if current_user.user_id != user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only query your own payments"
        )
    
    payment_service = PaymentService(db)
    payments = await payment_service.get_payments_by_id_user(user_id, skip=skip, limit=limit)
    return payments

@router.get("/booking/{booking_id}", response_model=List[PaymentResponse])
async def get_payments_by_booking(
    booking_id: str,
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Get payments for a specific booking"""
    payment_service = PaymentService(db)
    
    # Verify that the booking exists and the user has access
    booking = await payment_service.get_booking_by_id(booking_id)
    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Booking not found"
        )
    
    # Verify that the current user is the renter or host of the booking
    if booking.renter_id != current_user.user_id and booking.host_id != current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have access to payments for this booking"
        )
    
    payments = await payment_service.get_payments_by_id_booking(booking_id, skip=skip, limit=limit)
    return payments

@router.post("/", response_model=PaymentResponse)
async def create_payment(
    payment_data: PaymentCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Create a new payment"""
    # Verify that the current user is the payer
    if payment_data.payer_id != current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only create payments for yourself"
        )
    
    payment_service = PaymentService(db)
    
    try:
        payment = await payment_service.create_payment(payment_data)
        return payment
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.put("/{payment_id}", response_model=PaymentResponse)
async def update_payment(
    payment_id: str,
    payment_update: PaymentUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Update a payment"""
    payment_service = PaymentService(db)
    
    # Verify that the payment exists and belongs to the current user
    payment = await payment_service.get_payment(payment_id)
    if not payment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Payment not found"
        )
    
    if payment.payer_id != current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only update your own payments"
        )
    
    try:
        updated_payment = await payment_service.update_payment(payment_id, payment_update)
        return updated_payment
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.delete("/{payment_id}")
async def delete_payment(
    payment_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Delete a payment"""
    payment_service = PaymentService(db)
    
    # Verify that the payment exists and belongs to the current user
    payment = await payment_service.get_payment(payment_id)
    if not payment:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Payment not found"
        )
    
    if payment.payer_id != current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only delete your own payments"
        )
    
    success = await payment_service.delete_payment(payment_id)
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error deleting payment"
        )
    
    return {"message": "Payment deleted successfully"}
