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
    
    Calcula PRIMERO por usuario individual y luego promedia esos promedios.
    Esto da una mejor representación de cuánto usa cada usuario individualmente cada funcionalidad.
    
    Args:
        db: Sesión de base de datos async
        weeks: Número de semanas a considerar (default: 4, aprox 1 mes)
        threshold: Umbral mínimo de usos por semana por usuario (default: 2.0)
    
    Returns:
        Lista de diccionarios con feature_name y avg_uses_per_week_per_user
    """
    cutoff_date = datetime.utcnow() - timedelta(weeks=weeks)
    
    # Query SQL: Primero calcula por usuario, luego promedia los promedios individuales
    # Esto da una mejor métrica: el promedio de cuánto usa cada usuario individual
    query = text("""
        WITH user_weekly_avg AS (
            SELECT 
                feature_name,
                user_id,
                COUNT(*)::float / :weeks AS uses_per_week_per_user
            FROM feature_usage_log
            WHERE timestamp >= :cutoff_date
            GROUP BY feature_name, user_id
        )
        SELECT 
            feature_name,
            AVG(uses_per_week_per_user) AS avg_uses_per_week_per_user,
            SUM(uses_per_week_per_user * :weeks)::int AS total_uses,
            COUNT(DISTINCT user_id) AS unique_users
        FROM user_weekly_avg
        GROUP BY feature_name
        HAVING AVG(uses_per_week_per_user) < :threshold
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
    
    Calcula PRIMERO por usuario individual y luego promedia esos promedios.
    
    Args:
        db: Sesión de base de datos async
        feature_name: Nombre de funcionalidad específica (None para todas)
        weeks: Número de semanas a considerar
    
    Returns:
        Lista de estadísticas por funcionalidad
    """
    cutoff_date = datetime.utcnow() - timedelta(weeks=weeks)
    
    # Query SQL: Primero calcula por usuario, luego promedia
    base_query = text("""
        WITH user_weekly_avg AS (
            SELECT 
                feature_name,
                user_id,
                COUNT(*)::float / :weeks AS uses_per_week_per_user,
                COUNT(*)::int AS user_total_uses
            FROM feature_usage_log
            WHERE timestamp >= :cutoff_date
            GROUP BY feature_name, user_id
        )
        SELECT 
            feature_name,
            AVG(uses_per_week_per_user) AS avg_uses_per_week_per_user,
            SUM(user_total_uses)::int AS total_uses,
            COUNT(DISTINCT user_id) AS unique_users,
            AVG(uses_per_week_per_user) * :weeks AS avg_uses_per_user
        FROM user_weekly_avg
        GROUP BY feature_name
        ORDER BY total_uses DESC
    """)
    
    params = {
        "cutoff_date": cutoff_date,
        "weeks": float(weeks)
    }
    
    if feature_name:
        # Modificar la query para filtrar por feature_name
        query = text("""
            WITH user_weekly_avg AS (
                SELECT 
                    feature_name,
                    user_id,
                    COUNT(*)::float / :weeks AS uses_per_week_per_user,
                    COUNT(*)::int AS user_total_uses
                FROM feature_usage_log
                WHERE timestamp >= :cutoff_date AND feature_name = :feature_name
                GROUP BY feature_name, user_id
            )
            SELECT 
                feature_name,
                AVG(uses_per_week_per_user) AS avg_uses_per_week_per_user,
                SUM(user_total_uses)::int AS total_uses,
                COUNT(DISTINCT user_id) AS unique_users,
                AVG(uses_per_week_per_user) * :weeks AS avg_uses_per_user
            FROM user_weekly_avg
            GROUP BY feature_name
            ORDER BY total_uses DESC
        """)
        params["feature_name"] = feature_name
    else:
        query = base_query
    
    result = await db.execute(query, params)
    rows = result.fetchall()
    
    return [
        {
            "feature_name": row[0],
            "total_uses": int(row[2]),
            "unique_users": int(row[3]),
            "avg_uses_per_user": round(float(row[4]), 2) if row[4] else 0.0,
            "avg_uses_per_week_per_user": round(float(row[1]), 3) if row[1] else 0.0
        }
        for row in rows
    ]
