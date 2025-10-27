from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List

from pydantic import BaseModel

from app.db.base import get_db
from app.db.models import User
from app.schemas.user import UserResponse, UserUpdate
from app.core.security import get_current_user_token
from app.services.user_service import UserService


router = APIRouter(prefix="/users", tags=["users"])


class PaginatedUsersResponse(BaseModel):
    """
    Estructura de respuesta paginada para /users.
    items      -> lista de usuarios (serializados)
    total      -> número total de usuarios en la base
    skip/limit -> ventana pedida
    """
    items: List[UserResponse]
    total: int
    skip: int
    limit: int


async def get_current_user_from_token(
    token: dict = Depends(get_current_user_token),
    db: AsyncSession = Depends(get_db),
) -> User:
    """Obtiene el usuario actual a partir del token Bearer."""
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token requerido",
        )

    email = token.get("sub")
    if not email:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido",
        )

    result = await db.execute(select(User).where(User.email == email))
    user = result.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Usuario no encontrado",
        )

    return user


@router.get("/", response_model=PaginatedUsersResponse)
async def get_users(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """
    Obtiene lista paginada de usuarios.
    Soporta query params ?skip=&limit=

    Respuesta:
    {
      "items": [...],
      "total": 123,
      "skip": 0,
      "limit": 20
    }
    """

    # Aquí podrías agregar lógica para verificar si es admin, si quieres restringir.
    user_service = UserService(db)
    data = await user_service.get_users(skip=skip, limit=limit)

    # data["items"] son modelos ORM User;
    # convertimos cada uno a UserResponse (Pydantic) para que
    # la respuesta cumpla con response_model=PaginatedUsersResponse.
    serialized_items = [UserResponse.from_orm(u) for u in data["items"]]

    return {
        "items": serialized_items,
        "total": data["total"],
        "skip": data["skip"],
        "limit": data["limit"],
    }


@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """Obtiene un usuario específico por ID."""
    user_service = UserService(db)
    user = await user_service.get_user_by_id(user_id)

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Usuario no encontrado",
        )

    return user


@router.put("/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: str,
    user_update: UserUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """
    Actualiza el usuario autenticado.
    (Solo te dejo modificar tu propio perfil)
    """
    if current_user.user_id != user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Solo puedes actualizar tu propio perfil",
        )

    user_service = UserService(db)

    try:
        user = await user_service.update_user(user_id, user_update)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Usuario no encontrado",
            )
        return user
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )


@router.delete("/{user_id}")
async def delete_user(
    user_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """
    Soft delete:
    marca el usuario como 'suspended'
    """
    if current_user.user_id != user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Solo puedes eliminar tu propio perfil",
        )

    user_service = UserService(db)
    success = await user_service.delete_user(user_id)

    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Usuario no encontrado",
        )

    return {"message": "Usuario eliminado correctamente"}
