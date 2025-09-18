from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime
from app.db.models import UserStatus, DriverLicenseStatus

# Base schemas
class UserBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    email: EmailStr
    phone: str = Field(..., min_length=10, max_length=15)
    role: str = Field(..., pattern="^(host|renter|both)$")

class UserCreate(UserBase):
    password: str = Field(..., min_length=8, max_length=100)

class UserUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    email: Optional[EmailStr] = None
    phone: Optional[str] = Field(None, min_length=10, max_length=15)
    role: Optional[str] = Field(None, pattern="^(host|renter|both)$")
    driver_license_status: Optional[DriverLicenseStatus] = None
    status: Optional[UserStatus] = None

class UserResponse(UserBase):
    user_id: str
    driver_license_status: DriverLicenseStatus
    status: UserStatus
    created_at: datetime
    
    class Config:
        from_attributes = True

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"

class TokenData(BaseModel):
    email: Optional[str] = None
