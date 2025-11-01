"""
Decorator para trackear automáticamente el uso de funcionalidades.
"""

from functools import wraps
from typing import Callable, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from app.services.feature_tracking import log_feature_usage
from app.db.models import User


def track_feature_usage(feature_name: str, require_auth: bool = True):
    """
    Decorator para trackear automáticamente el uso de una funcionalidad.
    
    Usage:
        @router.post("/search")
        @track_feature_usage("search_filters")
        async def search_vehicles(..., current_user: User = Depends(...)):
            ...
        
        # Para endpoints sin autenticación, usar un user_id fijo o None
        @router.post("/public-search")
        @track_feature_usage("public_search", require_auth=False)
        async def public_search(...):
            ...
    
    Args:
        feature_name: Nombre de la funcionalidad a trackear
        require_auth: Si True, solo trackea cuando hay usuario autenticado
    """
    def decorator(func: Callable):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            # Extraer db y current_user de kwargs (vienen de Depends)
            db: Optional[AsyncSession] = kwargs.get("db")
            current_user: Optional[User] = kwargs.get("current_user")
            
            # Si require_auth=True y no hay usuario, no trackeamos
            if require_auth and not current_user:
                return await func(*args, **kwargs)
            
            # Si hay db, registramos el uso (con user_id si existe, o None)
            if db:
                user_id = current_user.user_id if current_user else "anonymous"
                try:
                    await log_feature_usage(db, user_id, feature_name)
                except Exception:
                    # Si falla el tracking, no afecta la operación principal
                    pass
            
            # Ejecutar la función original
            return await func(*args, **kwargs)
        
        return wrapper
    return decorator
