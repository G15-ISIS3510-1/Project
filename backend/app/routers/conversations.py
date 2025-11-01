from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List, Optional

from app.db.base import get_db
from app.db.models import User
from app.schemas.conversation import (
    ConversationResponse,
    ConversationCreateDirect,
    ConversationUpdate,
)
from app.services.conversation_service import ConversationService
from app.routers.users import get_current_user_from_token

router = APIRouter(tags=["conversations"])

@router.post("/direct", response_model=ConversationResponse, status_code=status.HTTP_201_CREATED)
async def ensure_direct_conversation(
    payload: ConversationCreateDirect,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    """Crea (o devuelve) una conversación directa 1–a–1 con `other_user_id`."""
    svc = ConversationService(db)
    try:
        conv = await svc.ensure_direct_conversation(
            user_a_id=current_user.user_id,
            user_b_id=payload.other_user_id,
        )
        return conv
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))

@router.get("/", response_model=List[ConversationResponse])
async def list_my_conversations(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    svc = ConversationService(db)
    return await svc.list_for_user(current_user.user_id, skip=skip, limit=limit)

@router.get("/{conversation_id}", response_model=ConversationResponse)
async def get_conversation(
    conversation_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    svc = ConversationService(db)
    conv = await svc.get_by_id_for_user(conversation_id, current_user.user_id)
    if not conv:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Conversación no encontrada")
    return conv

@router.put("/{conversation_id}", response_model=ConversationResponse)
async def update_conversation(
    conversation_id: str,
    payload: ConversationUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    svc = ConversationService(db)
    conv = await svc.update_title(conversation_id, current_user.user_id, payload)
    if not conv:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Conversación no encontrada o sin acceso")
    return conv

@router.delete("/{conversation_id}")
async def delete_conversation(
    conversation_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_from_token),
):
    svc = ConversationService(db)
    ok = await svc.delete(conversation_id, current_user.user_id)
    if not ok:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Conversación no encontrada o sin acceso")
    return {"message": "Conversación eliminada correctamente"}
