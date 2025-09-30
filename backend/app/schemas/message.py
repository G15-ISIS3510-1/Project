from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime


# =========================
# Base / Create / Update
# =========================

class MessageBase(BaseModel):
    content: str = Field(..., min_length=1, max_length=5000, description="Contenido del mensaje")
    conversation_id: Optional[str] = Field(
        None, description="ID de la conversación (opcional, si agrupas hilos)"
    )
    meta: Optional[Dict[str, Any]] = Field(
        default=None, description="Metadatos opcionales (ej. tipo, adjuntos, etc.)"
    )


class MessageCreate(MessageBase):
    receiver_id: str = Field(..., description="ID del usuario receptor del mensaje")


class MessageUpdate(BaseModel):
    content: Optional[str] = Field(
        None, min_length=1, max_length=5000, description="Nuevo contenido del mensaje"
    )


# =========================
# Responses
# =========================

class MessageResponse(MessageBase):
    message_id: str = Field(..., description="ID del mensaje")
    sender_id: str = Field(..., description="ID del usuario emisor")
    receiver_id: str = Field(..., description="ID del usuario receptor")
    created_at: datetime = Field(..., description="Fecha y hora de creación")
    read_at: Optional[datetime] = Field(None, description="Fecha y hora de lectura")

    class Config:
        from_attributes = True  # permite crear desde ORM objects


class MessageList(BaseModel):
    messages: List[MessageResponse] = Field(..., description="Lista de mensajes")
    total: int = Field(..., ge=0, description="Total de mensajes en la consulta")
    page: int = Field(..., ge=1, description="Página actual (1-index)")
    limit: int = Field(..., ge=1, description="Límite por página")


class UnreadCountResponse(BaseModel):
    unread: int = Field(..., ge=0, description="Cantidad de mensajes no leídos")
