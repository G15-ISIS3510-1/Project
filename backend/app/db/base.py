from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, declarative_base
from app.core.config import settings

# Crear engine asíncrono
engine = create_async_engine(
    settings.database_url_async,
    echo=settings.debug,
    future=True
)

# Crear sesión asíncrona
AsyncSessionLocal = sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False
)

# Base para los modelos
Base = declarative_base()

# Dependency para obtener la sesión de la base de datos
async def get_db():
    async with AsyncSessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()
