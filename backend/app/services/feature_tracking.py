"""
Servicio para trackear el uso de funcionalidades de la aplicación.
"""

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, text
from datetime import datetime, timedelta
from typing import Optional
from app.db.models import FeatureUsageLog


async def log_feature_usage(
    db: AsyncSession,
    user_id: str,
    feature_name: str
) -> None:
    """
    Registra el uso de una funcionalidad por un usuario.
    
    Args:
        db: Sesión de base de datos async
        user_id: ID del usuario
        feature_name: Nombre de la funcionalidad (ej: "search_filters", "chat_with_owner")
    """
    try:
        usage_log = FeatureUsageLog(
            user_id=user_id,
            feature_name=feature_name,
            timestamp=datetime.utcnow()
        )
        db.add(usage_log)
        await db.commit()
    except Exception as e:
        # Si falla el tracking, no debe afectar la operación principal
        await db.rollback()
        # En producción, podrías loguear el error


async def get_low_usage_features(
    db: AsyncSession,
    weeks: int = 4,
    threshold: float = 2.0
) -> list[dict]:
    """
    Obtiene las funcionalidades que se usan menos de 'threshold' veces por semana por usuario en promedio.
    
    Args:
        db: Sesión de base de datos async
        weeks: Número de semanas a considerar (default: 4, aprox 1 mes)
        threshold: Umbral mínimo de usos por semana por usuario (default: 2.0)
    
    Returns:
        Lista de diccionarios con feature_name y avg_uses_per_week_per_user
    """
    cutoff_date = datetime.utcnow() - timedelta(weeks=weeks)
    
    # Query SQL directa para calcular el promedio semanal
    query = text("""
        SELECT 
            feature_name,
            COUNT(*)::float / NULLIF(COUNT(DISTINCT user_id), 0) / :weeks AS avg_uses_per_week_per_user,
            COUNT(*) AS total_uses,
            COUNT(DISTINCT user_id) AS unique_users
        FROM feature_usage_log
        WHERE timestamp >= :cutoff_date
        GROUP BY feature_name
        HAVING COUNT(*)::float / NULLIF(COUNT(DISTINCT user_id), 0) / :weeks < :threshold
        ORDER BY avg_uses_per_week_per_user ASC
    """)
    
    result = await db.execute(
        query,
        {
            "cutoff_date": cutoff_date,
            "weeks": float(weeks),
            "threshold": threshold
        }
    )
    
    rows = result.fetchall()
    
    return [
        {
            "feature_name": row[0],
            "avg_uses_per_week_per_user": round(float(row[1]), 3) if row[1] else 0.0,
            "total_uses": int(row[2]),
            "unique_users": int(row[3])
        }
        for row in rows
    ]


async def get_feature_usage_stats(
    db: AsyncSession,
    feature_name: Optional[str] = None,
    weeks: int = 4
) -> list[dict]:
    """
    Obtiene estadísticas de uso de funcionalidades.
    
    Args:
        db: Sesión de base de datos async
        feature_name: Nombre de funcionalidad específica (None para todas)
        weeks: Número de semanas a considerar
    
    Returns:
        Lista de estadísticas por funcionalidad
    """
    cutoff_date = datetime.utcnow() - timedelta(weeks=weeks)
    
    query = select(
        FeatureUsageLog.feature_name,
        func.count(FeatureUsageLog.id).label("total_uses"),
        func.count(func.distinct(FeatureUsageLog.user_id)).label("unique_users"),
        func.count(FeatureUsageLog.id).label("total_count")
    ).where(
        FeatureUsageLog.timestamp >= cutoff_date
    )
    
    if feature_name:
        query = query.where(FeatureUsageLog.feature_name == feature_name)
    
    query = query.group_by(FeatureUsageLog.feature_name).order_by(
        func.count(FeatureUsageLog.id).desc()
    )
    
    result = await db.execute(query)
    rows = result.all()
    
    return [
        {
            "feature_name": row.feature_name,
            "total_uses": row.total_uses,
            "unique_users": row.unique_users,
            "avg_uses_per_user": round(row.total_uses / row.unique_users if row.unique_users > 0 else 0, 2),
            "avg_uses_per_week_per_user": round((row.total_uses / row.unique_users if row.unique_users > 0 else 0) / weeks, 2)
        }
        for row in rows
    ]
