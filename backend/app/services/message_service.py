from __future__ import annotations

import uuid
from datetime import datetime, timezone
from typing import Optional, List, Dict, Any

from sqlalchemy import func, select, and_, or_, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import Message, User
from app.schemas.message import MessageCreate, MessageUpdate
from app.services.conversation_service import ConversationService


class MessageService:
    def __init__(self, db: AsyncSession):
        self.db = db

    # -----------------
    # Lectura básica
    # -----------------
    async def get_by_id(self, message_id: str) -> Optional[Message]:
        """Obtener un mensaje por ID."""
        res = await self.db.execute(
            select(Message).where(Message.message_id == message_id)
        )
        return res.scalar_one_or_none()

    # -----------------
    # Listados (paginados)
    # -----------------
    async def list_messages_for_user(
        self,
        user_id: str,
        skip: int = 0,
        limit: int = 100,
        only_unread: bool = False,
    ) -> Dict[str, Any]:
        """
        Listar mensajes donde el usuario es emisor o receptor.
        Si only_unread=True, retorna solo los recibidos y no leídos.
        Devuelve { items, total, skip, limit }.
        """
        if only_unread:
            base_condition = and_(
                Message.receiver_id == user_id,
                Message.read_at.is_(None),
            )
        else:
            base_condition = or_(
                Message.sender_id == user_id,
                Message.receiver_id == user_id,
            )

        # total
        count_q = await self.db.execute(
            select(func.count(Message.message_id)).where(base_condition)
        )
        total = count_q.scalar() or 0

        # page
        page_q = await self.db.execute(
            select(Message)
            .where(base_condition)
            .order_by(Message.created_at.desc())
            .offset(skip)
            .limit(limit)
        )
        rows = page_q.scalars().all()

        return {
            "items": rows,
            "total": total,
            "skip": skip,
            "limit": limit,
        }

    async def list_thread(
        self,
        user_a_id: str,
        user_b_id: str,
        skip: int = 0,
        limit: int = 100,
        only_unread: bool = False,
    ) -> Dict[str, Any]:
        """
        Listar el hilo entre user_a y user_b.
        Si only_unread=True, filtra solo los mensajes no leídos por user_a
        (o sea, recibidos por user_a).
        Devuelve { items, total, skip, limit }.
        """
        if only_unread:
            # SOLO los mensajes que me envió el otro y que yo no he leído
            base_condition = and_(
                Message.sender_id == user_b_id,
                Message.receiver_id == user_a_id,
                Message.read_at.is_(None),
            )
        else:
            base_condition = or_(
                and_(
                    Message.sender_id == user_a_id,
                    Message.receiver_id == user_b_id,
                ),
                and_(
                    Message.sender_id == user_b_id,
                    Message.receiver_id == user_a_id,
                ),
            )

        # total
        count_q = await self.db.execute(
            select(func.count(Message.message_id)).where(base_condition)
        )
        total = count_q.scalar() or 0

        # page
        page_q = await self.db.execute(
            select(Message)
            .where(base_condition)
            .order_by(Message.created_at.desc())
            .offset(skip)
            .limit(limit)
        )
        rows = page_q.scalars().all()

        return {
            "items": rows,
            "total": total,
            "skip": skip,
            "limit": limit,
        }

    # -----------------
    # Contadores
    # -----------------
    async def count_unread(self, user_id: str) -> int:
        """Contar mensajes no leídos del usuario (recibidos por él)."""
        res = await self.db.execute(
            select(Message).where(
                and_(
                    Message.receiver_id == user_id,
                    Message.read_at.is_(None),
                )
            )
        )
        # más eficiente sería select(func.count()), pero mantenemos la idea simple
        return len(res.scalars().all())

    # -----------------
    # Crear
    # -----------------
    async def create_message(
        self,
        sender_id: str,
        receiver_id: str,
        content: str,
        conversation_id: Optional[str] = None,
        meta: Optional[dict] = None,
    ) -> Message:
        """Crear y persistir un nuevo mensaje."""
        now = datetime.now(timezone.utc)

        if conversation_id is None:
            conv = await ConversationService(self.db).ensure_direct_conversation(
                user_a_id=sender_id,
                user_b_id=receiver_id,
            )
            conversation_id = conv.conversation_id

        message = Message(
            message_id=str(uuid.uuid4()),
            sender_id=sender_id,
            receiver_id=receiver_id,
            content=content,
            conversation_id=conversation_id,
            meta=meta,
            created_at=now,
            read_at=None,
        )
        self.db.add(message)
        await self.db.commit()
        await self.db.refresh(message)

        await ConversationService(self.db).touch_last_message(conversation_id)
        return message

    # -----------------
    # Marcar como leído
    # -----------------
    async def mark_as_read(self, message_id: str, reader_id: str) -> None:
        """
        Marcar un mensaje como leído por el receptor.
        No falla si ya estaba leído.
        """
        msg = await self.get_by_id(message_id)
        if not msg:
            return
        if msg.receiver_id != reader_id:
            return
        if msg.read_at is None:
            msg.read_at = datetime.now(timezone.utc)
            self.db.add(msg)
            await self.db.commit()

    async def mark_thread_as_read(self, reader_id: str, other_user_id: str) -> int:
        """
        Marcar como leídos todos los mensajes enviados por other_user_id y
        recibidos por reader_id que aún estén sin leer.
        Retorna cuántos mensajes se actualizaron.
        """
        stmt = (
            update(Message)
            .where(
                ((Message.sender_id == other_user_id) & (Message.receiver_id == reader_id))
                & (Message.read_at.is_(None))
            )
            .values(read_at=func.now())
            .execution_options(synchronize_session=False)
        )
        res = await self.db.execute(stmt)
        await self.db.commit()
        return res.rowcount or 0

    # -----------------
    # Actualizar contenido
    # -----------------
    async def update_message(self, message_id: str, content: str) -> Optional[Message]:
        """
        Actualizar el contenido del mensaje.
        (La validación de permisos se hace en el router).
        """
        msg = await self.get_by_id(message_id)
        if not msg:
            return None

        msg.content = content
        self.db.add(msg)
        await self.db.commit()
        await self.db.refresh(msg)
        return msg

    # -----------------
    # Eliminar
    # -----------------
    async def delete_message(self, message_id: str) -> bool:
        """Eliminar un mensaje (duro). Retorna True si se eliminó."""
        msg = await self.get_by_id(message_id)
        if not msg:
            return False

        await self.db.delete(msg)
        await self.db.commit()
        return True

    # -----------------
    # Utilidades auxiliares (opcionales)
    # -----------------
    async def ensure_user_exists(self, user_id: str) -> Optional[User]:
        """Verificar existencia de usuario."""
        res = await self.db.execute(
            select(User).where(User.user_id == user_id)
        )
        return res.scalar_one_or_none()
