from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from typing import Optional, List, Dict, Any, Tuple
from app.db.models import User
from app.schemas.user import UserCreate, UserUpdate
from app.core.security import get_password_hash, verify_password
import uuid


class UserService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_user(self, user_data: UserCreate) -> User:
        """Crear (o reutilizar) un usuario con lógica de negocio de roles."""
        desired_role = (user_data.role or "renter").lower()
        if desired_role not in ("renter", "host", "both"):
            raise ValueError("Rol inválido. Debe ser 'renter' o 'host' o 'both'.")

        existing = await self.get_user_by_email(user_data.email)

        # Caso 1: no existe -> crearlo
        if not existing:
            hashed = get_password_hash(user_data.password)

            # si viene "both" lo guardamos como "both",
            # si no, usamos lo que pidió
            role_to_set = "both" if desired_role == "both" else desired_role

            user = User(
                user_id=str(uuid.uuid4()),
                name=user_data.name,
                email=user_data.email,
                phone=user_data.phone,
                role=role_to_set,
                password=hashed,
                status="active",
            )
            self.db.add(user)
            await self.db.commit()
            await self.db.refresh(user)
            return user, "created"

        # Caso 2: existe pero password no coincide -> error
        if not verify_password(user_data.password, existing.password):
            raise ValueError("El email ya está registrado")

        # Caso 3: ya existe con pass correcto
        current_role = (existing.role or "renter").lower()

        # ya es both, no hay nada que mejorar
        if current_role == "both":
            return existing, "already_registered"

        # si ya tiene exactamente el mismo rol
        if current_role == desired_role:
            return existing, "already_registered"

        # fusionar renter/host => both
        if {current_role, desired_role} == {"renter", "host"}:
            existing.role = "both"
            await self.db.commit()
            await self.db.refresh(existing)
            return existing, "upgraded_to_both"

        # pedir "both" explícitamente también sube a both
        if desired_role == "both" and current_role in {"renter", "host"}:
            existing.role = "both"
            await self.db.commit()
            await self.db.refresh(existing)
            return existing, "upgraded_to_both"

        # fallback
        return existing, "already_registered"

    async def get_user_by_id(self, user_id: str) -> Optional[User]:
        """Obtener usuario por ID."""
        result = await self.db.execute(
            select(User).where(User.user_id == user_id)
        )
        return result.scalar_one_or_none()

    async def get_user_by_email(self, email: str) -> Optional[User]:
        """Obtener usuario por email."""
        result = await self.db.execute(
            select(User).where(User.email == email)
        )
        return result.scalar_one_or_none()

    async def get_users(
        self,
        skip: int = 0,
        limit: int = 100,
    ) -> Dict[str, Any]:
        """
        Obtener lista de usuarios con paginación.

        Retorna un dict con:
        {
          "items": [User, User, ...],  # chunk paginado
          "total": 123,                # total de usuarios en la DB
          "skip": skip,
          "limit": limit
        }

        Esto permite al frontend hacer paginación tipo offset/limit.
        """

        # Total de registros (sin paginar)
        total_result = await self.db.execute(
            select(func.count()).select_from(User)
        )
        total = total_result.scalar_one() or 0

        # Chunk paginado
        result = await self.db.execute(
            select(User)
            .offset(skip)
            .limit(limit)
        )
        users = result.scalars().all()

        return {
            "items": users,
            "total": total,
            "skip": skip,
            "limit": limit,
        }

    async def update_user(
        self,
        user_id: str,
        user_update: UserUpdate
    ) -> Optional[User]:
        """Actualizar usuario con validaciones de negocio."""
        user = await self.get_user_by_id(user_id)
        if not user:
            return None

        update_data = user_update.dict(exclude_unset=True)

        # Validaciones de negocio
        if "email" in update_data:
            existing_user = await self.get_user_by_email(update_data["email"])
            if existing_user and existing_user.user_id != user_id:
                raise ValueError("El email ya está en uso por otro usuario")

        # Aplicar cambios en el modelo
        for field, value in update_data.items():
            setattr(user, field, value)

        await self.db.commit()
        await self.db.refresh(user)
        return user

    async def delete_user(self, user_id: str) -> bool:
        """Soft delete - marcar status en 'suspended'."""
        user = await self.get_user_by_id(user_id)
        if not user:
            return False

        user.status = "suspended"
        await self.db.commit()
        return True

    async def authenticate_user(
        self,
        email: str,
        password: str
    ) -> Optional[User]:
        """Autenticar (login)."""
        user = await self.get_user_by_email(email)
        if not user or not verify_password(password, user.password):
            return None
        return user
