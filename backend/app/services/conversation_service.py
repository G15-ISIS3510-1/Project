from __future__ import annotations

import uuid
from datetime import datetime, timezone
from typing import Optional, List, Dict, Any

from sqlalchemy import select, or_, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import Conversation
from app.schemas.conversation import ConversationUpdate

class ConversationService:
    def __init__(self, db: AsyncSession):
        self.db = db

    @staticmethod
    def _normalize_pair(user_a_id: str, user_b_id: str) -> tuple[str, str]:
        if user_a_id == user_b_id:
            # Evita conversaciones contra sí mismo
            raise ValueError("No se puede crear conversación con uno mismo")
        low, high = sorted([user_a_id, user_b_id])
        return low, high

    async def ensure_direct_conversation(
        self, user_a_id: str, user_b_id: str, title: Optional[str] = None
    ) -> Conversation:
        """Devuelve la conversación 1–a–1 si existe; de lo contrario la crea."""
        low, high = self._normalize_pair(user_a_id, user_b_id)

        res = await self.db.execute(
            select(Conversation).where(
                Conversation.user_low_id == low,
                Conversation.user_high_id == high,
            )
        )
        conv = res.scalar_one_or_none()
        if conv:
            return conv

        conv = Conversation(
            conversation_id=str(uuid.uuid4()),
            user_low_id=low,
            user_high_id=high,
            title=title,
            created_at=datetime.now(timezone.utc),
            last_message_at=None,
        )
        self.db.add(conv)
        await self.db.commit()
        await self.db.refresh(conv)
        return conv

    async def get_by_id_for_user(self, conversation_id: str, user_id: str) -> Optional[Conversation]:
        """Obtiene una conversación si el usuario es participante."""
        res = await self.db.execute(
            select(Conversation).where(
                Conversation.conversation_id == conversation_id,
                or_(
                    Conversation.user_low_id == user_id,
                    Conversation.user_high_id == user_id,
                ),
            )
        )
        return res.scalar_one_or_none()

    async def list_for_user(
        self, user_id: str, skip: int = 0, limit: int = 100
    ) -> Dict[str, Any]:
        """Lista conversaciones del usuario, ordenadas por actividad reciente."""
        base_cond = or_(
            Conversation.user_low_id == user_id,
            Conversation.user_high_id == user_id,
        )

        total_q = await self.db.execute(
            select(func.count(Conversation.conversation_id)).where(base_cond)
        )
        total = total_q.scalar() or 0

        page_q = await self.db.execute(
            select(Conversation)
            .where(base_cond)
            .order_by(Conversation.last_message_at.desc().nullslast())
            .offset(skip)
            .limit(limit)
        )
        items = page_q.scalars().all()

        return {
            "items": items,
            "total": total,
            "skip": skip,
            "limit": limit,
        }

    async def update_title(self, conversation_id: str, user_id: str, payload: ConversationUpdate) -> Optional[Conversation]:
        conv = await self.get_by_id_for_user(conversation_id, user_id)
        if not conv:
            return None
        data = payload.model_dump(exclude_unset=True)
        if "title" in data:
            conv.title = data["title"]
            self.db.add(conv)
            await self.db.commit()
            await self.db.refresh(conv)
        return conv

    async def touch_last_message(self, conversation_id: str) -> None:
        """Actualiza last_message_at a ahora; úsalo al enviar mensajes."""
        res = await self.db.execute(
            select(Conversation).where(Conversation.conversation_id == conversation_id)
        )
        conv = res.scalar_one_or_none()
        if not conv:
            return
        conv.last_message_at = datetime.now(timezone.utc)
        self.db.add(conv)
        await self.db.commit()

    async def delete(self, conversation_id: str, user_id: str) -> bool:
        """Elimina definitivamente (si el usuario pertenece). Cambia a soft delete si lo necesitas."""
        conv = await self.get_by_id_for_user(conversation_id, user_id)
        if not conv:
            return False
        await self.db.delete(conv)
        await self.db.commit()
        return True
