from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime

class ConversationBase(BaseModel):
    title: Optional[str] = Field(None, description="Título opcional del hilo")

class ConversationCreateDirect(BaseModel):
    other_user_id: str = Field(..., description="Usuario con quien abrir (o reutilizar) la conversación")

class ConversationUpdate(BaseModel):
    title: Optional[str] = Field(None, description="Nuevo título del hilo")

class ConversationResponse(ConversationBase):
    conversation_id: str
    user_low_id: str
    user_high_id: str
    created_at: datetime
    last_message_at: Optional[datetime] = None

    class Config:
        from_attributes = True

class ConversationList(BaseModel):
    conversations: List[ConversationResponse]
    total: int
    page: int
    limit: int
