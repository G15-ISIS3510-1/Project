from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import JSONResponse
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.db.base import get_db
from app.db.models import User
from app.schemas.user import UserCreate, UserResponse, Token, UserLogin
from app.core.security import get_password_hash, verify_password, create_access_token
import uuid

router = APIRouter(prefix="/auth", tags=["authentication"])

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

@router.post("/register", response_model=UserResponse)
async def register(user_data: UserCreate, db: AsyncSession = Depends(get_db)):
    """Registra un nuevo usuario"""
    # Verificar si el email ya existe
    desired_role = (user_data.role or "renter").lower()
    if desired_role not in ("renter", "host", "both"):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST,
                            detail="Rol inválido. Usa 'renter', 'host' o 'both'.")

    result = await db.execute(select(User).where(User.email == user_data.email))
    existing_user = result.scalar_one_or_none()

    if not existing_user:
        role_to_set = "both" if desired_role == "both" else desired_role
        hashed_password = get_password_hash(user_data.password)
        new_user = User(
            user_id=str(uuid.uuid4()),
            name=user_data.name,
            email=user_data.email,
            password=hashed_password,
            phone=user_data.phone,
            role=role_to_set,
            status="active",
        )
        db.add(new_user)
        await db.commit()
        await db.refresh(new_user)
        # 201 Created con cuerpo del usuario
        return new_user

    current_role = (existing_user.role or "renter").lower()

    if current_role == "both":
        raise HTTPException(status_code=status.HTTP_409_CONFLICT,
                            detail="Ya estás registrado con ambos roles.")     

    if current_role == desired_role:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT,
                            detail="Ya estás registrado con ese rol.")

    if not verify_password(user_data.password, existing_user.password):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST,
                            detail="El email ya está registrado. Usa la misma contraseña para fusionar a ambos roles.")
          
    existing_user.role = "both"
    await db.commit()
    await db.refresh(existing_user)
    # 200 OK con cuerpo del usuario actualizado
    return existing_user

@router.post("/login", response_model=Token)
async def login(user_credentials: UserLogin, db: AsyncSession = Depends(get_db)):
    """Autentica un usuario y retorna un token JWT"""
    # Buscar usuario por email
    result = await db.execute(select(User).where(User.email == user_credentials.email))
    user = result.scalar_one_or_none()
    
    if not user or not verify_password(user_credentials.password, user.password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciales incorrectas"
        )
    
    if user.status != "active":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Usuario suspendido"
        )
    
    # Crear token de acceso
    access_token = create_access_token(data={"sub": user.email})
    
    return {"access_token": access_token, "token_type": "bearer"}

@router.get("/me", response_model=UserResponse)
async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db)
):
    """Obtiene la información del usuario autenticado"""
    from app.core.security import verify_token
    
    payload = verify_token(token)
    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido"
        )
    
    email = payload.get("sub")
    if not email:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido"
        )
    
    result = await db.execute(select(User).where(User.email == email))
    user = result.scalar_one_or_none()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Usuario no encontrado"
        )
    
    return user
