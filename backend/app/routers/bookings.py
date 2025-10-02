from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.base import get_db
from app.db.models import User
from app.schemas.booking import BookingResponse, BookingCreate, BookingUpdate
from app.services.booking_service import BookingService
from app.routers.users import get_current_user_from_token
from typing import List

router = APIRouter(prefix="/bookings", tags=["bookings"])

@router.get("/", response_model=List[BookingResponse])
async def get_bookings(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Get list of bookings (admin only)"""
    # In a real case, here you would verify if the user is an administrator
    booking_service = BookingService(db)
    bookings = await booking_service.get_bookings(skip=skip, limit=limit)
    return bookings

@router.get("/{booking_id}", response_model=BookingResponse)
async def get_booking(
    booking_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Get a specific booking by ID"""
    booking_service = BookingService(db)
    booking = await booking_service.get_booking(booking_id)
    
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
    
    return booking

@router.get("/user/renter", response_model=List[BookingResponse])
async def get_bookings_as_renter(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Get bookings where the current user is the renter"""
    booking_service = BookingService(db)
    bookings = await booking_service.get_bookings_by_id_user(
        current_user.user_id, as_renter=True, skip=skip, limit=limit
    )
    return bookings

@router.get("/user/host", response_model=List[BookingResponse])
async def get_bookings_as_host(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Get bookings where the current user is the host"""
    booking_service = BookingService(db)
    bookings = await booking_service.get_bookings_by_id_user(
        current_user.user_id, as_renter=False, skip=skip, limit=limit
    )
    return bookings

@router.get("/vehicle/{vehicle_id}", response_model=List[BookingResponse])
async def get_bookings_by_vehicle(
    vehicle_id: str,
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Get bookings for a specific vehicle"""
    booking_service = BookingService(db)
    
    # Verify that the vehicle exists
    vehicle = await booking_service.get_vehicle_by_id(vehicle_id)
    if not vehicle:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Vehicle not found"
        )
    
    # Verify that the current user is the owner of the vehicle
    if vehicle.owner_id != current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only query bookings for your own vehicles"
        )
    
    bookings = await booking_service.get_bookings_by_id_vehicle(vehicle_id, skip=skip, limit=limit)
    return bookings

@router.get("/insurance-plan/{insurance_plan_id}", response_model=List[BookingResponse])
async def get_bookings_by_insurance_plan(
    insurance_plan_id: str,
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Get bookings with a specific insurance plan (admin only)"""
    # In a real case, here you would verify if the user is an administrator
    booking_service = BookingService(db)
    
    # Verify that the insurance plan exists
    insurance_plan = await booking_service.get_insurance_plan_by_id(insurance_plan_id)
    if not insurance_plan:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Insurance plan not found"
        )
    
    bookings = await booking_service.get_bookings_by_id_insurance_plan(insurance_plan_id, skip=skip, limit=limit)
    return bookings

@router.post("/", response_model=BookingResponse)
async def create_booking(
    booking_data: BookingCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Create a new booking"""
    # Verify that the current user is the renter
    if booking_data.renter_id != current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only create bookings for yourself as renter"
        )
    
    booking_service = BookingService(db)
    
    try:
        booking = await booking_service.create_booking(booking_data)
        return booking
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.put("/{booking_id}", response_model=BookingResponse)
async def update_booking(
    booking_id: str,
    booking_update: BookingUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Update a booking"""
    booking_service = BookingService(db)
    
    # Verify that the booking exists
    booking = await booking_service.get_booking(booking_id)
    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Booking not found"
        )
    
    # Verify that the current user has access to the booking
    if booking.renter_id != current_user.user_id and booking.host_id != current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only update bookings you participate in"
        )
    
    try:
        updated_booking = await booking_service.update_booking(booking_id, booking_update)
        return updated_booking
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.delete("/{booking_id}")
async def delete_booking(
    booking_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token)
):
    """Delete/cancel a booking"""
    booking_service = BookingService(db)
    
    # Verify that the booking exists
    booking = await booking_service.get_booking(booking_id)
    if not booking:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Booking not found"
        )
    
    # Verify that the current user can cancel the booking
    # Generally only the renter can cancel, or the host in specific cases
    if booking.renter_id != current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only the renter can cancel the booking"
        )
    
    try:
        success = await booking_service.delete_booking(booking_id)
        
        if not success:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Error canceling booking"
            )
        
        return {"message": "Booking canceled successfully"}
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
