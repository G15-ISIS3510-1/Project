from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List, Optional

from pydantic import BaseModel

from app.db.base import get_db
from app.db.models import User
from app.schemas.message import MessageResponse, MessageCreate, MessageUpdate
from app.services.message_service import MessageService
from app.routers.users import get_current_user_from_token
from app.utils.feature_tracking_decorator import track_feature_usage

router = APIRouter(tags=["messages"])


# ---------- pagination response model ----------

class PaginatedMessageResponse(BaseModel):
    items: List[MessageResponse]
    total: int
    skip: int
    limit: int


# -------------------------
# Helpers
# -------------------------
async def _ensure_user_exists(db: AsyncSession, user_id: str) -> User:
    res = await db.execute(select(User).where(User.user_id == user_id))
    user = res.scalar_one_or_none()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Usuario no encontrado"
        )
    return user


# -------------------------
# Endpoints
# -------------------------

# Root collection — GET
@router.get("", response_model=PaginatedMessageResponse)
async def list_my_messages(
    skip: int = 0,
    limit: int = 100,
    other_user_id: Optional[str] = Query(
        None,
        description="Filtra la conversación con otro usuario específico"
    ),
    only_unread: bool = Query(
        False,
        description="Solo mensajes no leídos para el usuario actual"
    ),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """
    Listar mensajes del usuario actual (inbox + enviados) con paginación.
    Si `other_user_id` está presente, devuelve solo el hilo entre ambos usuarios.
    """
    svc = MessageService(db)

    if other_user_id:
        await _ensure_user_exists(db, other_user_id)
        data = await svc.list_thread(
            user_a_id=current_user.user_id,
            user_b_id=other_user_id,
            skip=skip,
            limit=limit,
            only_unread=only_unread,
        )
    else:
        data = await svc.list_messages_for_user(
            user_id=current_user.user_id,
            skip=skip,
            limit=limit,
            only_unread=only_unread,
        )

    serialized = [MessageResponse.from_orm(m) for m in data["items"]]

    return {
        "items": serialized,
        "total": data["total"],
        "skip": data["skip"],
        "limit": data["limit"],
    }


# Trailing-slash alias (hidden from schema) so /api/messages/ also works
@router.get("/", response_model=PaginatedMessageResponse, include_in_schema=False)
async def list_my_messages_alias(
    skip: int = 0,
    limit: int = 100,
    other_user_id: Optional[str] = Query(None),
    only_unread: bool = Query(False),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    data = await list_my_messages(
        skip=skip,
        limit=limit,
        other_user_id=other_user_id,
        only_unread=only_unread,
        db=db,
        current_user=current_user,
    )
    return data


@router.get("/unread/count")
async def unread_count(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """Contar mensajes no leídos para el usuario actual."""
    svc = MessageService(db)
    count = await svc.count_unread(user_id=current_user.user_id)
    return {"unread": count}


@router.get("/{message_id}", response_model=MessageResponse)
async def get_message(
    message_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """Obtener un mensaje por ID (solo si eres emisor o receptor)."""
    svc = MessageService(db)
    msg = await svc.get_by_id(message_id)
    if not msg:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Mensaje no encontrado"
        )
    if current_user.user_id not in (msg.sender_id, msg.receiver_id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="No tienes acceso a este mensaje"
        )
    return msg


@router.get("/thread/{other_user_id}", response_model=PaginatedMessageResponse)
async def get_thread_with_user(
    other_user_id: str,
    skip: int = 0,
    limit: int = 100,
    mark_as_read: bool = Query(
        False,
        description="Marcar como leídos los mensajes recibidos en este hilo"
    ),
    only_unread: bool = Query(
        False,
        description="Solo mensajes no leídos (recibidos por el usuario actual)"
    ),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """Obtener el hilo entre el usuario actual y `other_user_id`, paginado."""
    await _ensure_user_exists(db, other_user_id)
    svc = MessageService(db)
    data = await svc.list_thread(
        user_a_id=current_user.user_id,
        user_b_id=other_user_id,
        skip=skip,
        limit=limit,
        only_unread=only_unread,
    )

    if mark_as_read and data["items"]:
        await svc.mark_thread_as_read(
            reader_id=current_user.user_id,
            other_user_id=other_user_id
        )

    serialized = [MessageResponse.from_orm(m) for m in data["items"]]

    return {
        "items": serialized,
        "total": data["total"],
        "skip": data["skip"],
        "limit": data["limit"],
    }


# Root collection — POST
@router.post("", response_model=MessageResponse, status_code=status.HTTP_201_CREATED)
@track_feature_usage("chat_with_owner")
async def send_message(
    payload: MessageCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """
    Enviar un mensaje.
    Reglas:
    - `receiver_id` debe existir.
    - No se permite enviarse mensajes a sí mismo.
    """
    if payload.receiver_id == current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No puedes enviarte un mensaje a ti mismo"
        )

    await _ensure_user_exists(db, payload.receiver_id)
    svc = MessageService(db)
    msg = await svc.create_message(
        sender_id=current_user.user_id,
        receiver_id=payload.receiver_id,
        content=payload.content,
        conversation_id=getattr(payload, "conversation_id", None),
        meta=payload.meta,
    )
    return msg


# Trailing-slash alias for POST (hidden)
@router.post("/", response_model=MessageResponse,
             status_code=status.HTTP_201_CREATED,
             include_in_schema=False)
async def send_message_alias(
    payload: MessageCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    return await send_message(payload, db, current_user)


@router.post("/{message_id}/read")
async def mark_message_as_read(
    message_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """Marcar un mensaje como leído (solo el receptor)."""
    svc = MessageService(db)
    msg = await svc.get_by_id(message_id)
    if not msg:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Mensaje no encontrado"
        )
    if msg.receiver_id != current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Solo el receptor puede marcar como leído"
        )
    await svc.mark_as_read(message_id=message_id, reader_id=current_user.user_id)
    return {"message": "Mensaje marcado como leído"}


@router.put("/{message_id}", response_model=MessageResponse)
async def update_message(
    message_id: str,
    payload: MessageUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """Editar el contenido de un mensaje (solo el emisor)."""
    svc = MessageService(db)
    msg = await svc.get_by_id(message_id)
    if not msg:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Mensaje no encontrado"
        )
    if msg.sender_id != current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Solo el emisor puede editar el mensaje"
        )

    updated = await svc.update_message(
        message_id=message_id,
        content=payload.content
    )
    return updated


@router.delete("/{message_id}")
async def delete_message(
    message_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """Eliminar un mensaje (solo el emisor puede borrar su mensaje)."""
    svc = MessageService(db)
    msg = await svc.get_by_id(message_id)
    if not msg:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Mensaje no encontrado"
        )
    if msg.sender_id != current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Solo el emisor puede eliminar el mensaje"
        )

    ok = await svc.delete_message(message_id=message_id)
    if not ok:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="No se pudo eliminar el mensaje"
        )
    return {"message": "Mensaje eliminado correctamente"}


@router.post("/thread/{other_user_id}/read")
async def mark_thread_as_read(
    other_user_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """Marcar como leídos todos los mensajes recibidos en el hilo con `other_user_id`."""
    await _ensure_user_exists(db, other_user_id)
    svc = MessageService(db)
    affected = await svc.mark_thread_as_read(
        reader_id=current_user.user_id,
        other_user_id=other_user_id,
    )
    return {"marked": affected}
