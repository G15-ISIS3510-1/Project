from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import Optional, List
from app.db.models import User
from app.schemas.user import UserCreate, UserUpdate
from app.core.security import get_password_hash, verify_password
import uuid

class UserService:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def create_user(self, user_data: UserCreate) -> User:
        """Crear un nuevo usuario con lógica de negocio"""
        # Verificar si el email ya existe
        existing_user = await self.get_user_by_email(user_data.email)
        if existing_user:
            raise ValueError("El email ya está registrado")
        
        hashed_password = get_password_hash(user_data.password)
        
        # Crear usuario
        user = User(
            user_id=str(uuid.uuid4()),
            name=user_data.name,
            email=user_data.email,
            phone=user_data.phone,
            role=user_data.role,
            password=hashed_password
        )
        
        self.db.add(user)
        await self.db.commit()
        await self.db.refresh(user)
        return user
    
    async def get_user_by_id(self, user_id: str) -> Optional[User]:
        """Obtener usuario por ID"""
        result = await self.db.execute(select(User).where(User.user_id == user_id))
        return result.scalar_one_or_none()
    
    async def get_user_by_email(self, email: str) -> Optional[User]:
        """Obtener usuario por email"""
        result = await self.db.execute(select(User).where(User.email == email))
        return result.scalar_one_or_none()
    
    async def get_users(self, skip: int = 0, limit: int = 100) -> List[User]:
        """Obtener lista de usuarios con paginación"""
        result = await self.db.execute(select(User).offset(skip).limit(limit))
        return result.scalars().all()
    
    async def update_user(self, user_id: str, user_update: UserUpdate) -> Optional[User]:
        """Actualizar usuario con validaciones de negocio"""
        user = await self.get_user_by_id(user_id)
        if not user:
            return None
        
        # Actualizar solo campos proporcionados
        update_data = user_update.dict(exclude_unset=True)
        
        # Validaciones de negocio
        if "email" in update_data:
            existing_user = await self.get_user_by_email(update_data["email"])
            if existing_user and existing_user.user_id != user_id:
                raise ValueError("El email ya está en uso por otro usuario")
        
        # Aplicar cambios
        for field, value in update_data.items():
            setattr(user, field, value)
        
        await self.db.commit()
        await self.db.refresh(user)
        return user
    
    async def delete_user(self, user_id: str) -> bool:
        """Soft delete - cambiar status a suspended"""
        user = await self.get_user_by_id(user_id)
        if not user:
            return False
        
        user.status = "suspended"
        await self.db.commit()
        return True
    
    async def authenticate_user(self, email: str, password: str) -> Optional[User]:
        """Autenticar usuario"""
        user = await self.get_user_by_email(email)
        if not user or not verify_password(password, user.password):
            return None
        return user

