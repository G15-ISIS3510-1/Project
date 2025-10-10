# app/db/base.py

from __future__ import annotations

import os
import re
import logging
from typing import AsyncGenerator, Generator, Optional

from sqlalchemy.orm import declarative_base, sessionmaker
from sqlalchemy import create_engine

from sqlalchemy.ext.asyncio import (
    create_async_engine,
    AsyncSession,
)

# If you have a settings object, we still allow it as a fallback.
try:
    from app.core.config import settings  # optional
except Exception:  # pragma: no cover
    settings = None  # type: ignore

Base = declarative_base()

# Prefer env var so Alembic / runtime can control behavior;
# fall back to settings.database_url if present.
DATABASE_URL: str = (
    os.getenv("DATABASE_URL")
    or (getattr(settings, "database_url", None) if settings else None)
    or ""
)

if not DATABASE_URL:
    raise RuntimeError("DATABASE_URL is not set")

# Mask password for logs
masked = re.sub(r":([^:@/]+)@", r":***@", DATABASE_URL)
logging.getLogger("uvicorn.error").info("DB URL: %s", masked)

USE_ASYNC = DATABASE_URL.startswith("https://qovo-api-gfa6drobhq-uc.a.run.app")

if USE_ASYNC:
    # -------- ASYNC engine/session (FastAPI runtime) --------
    engine = create_async_engine(
        DATABASE_URL,
        echo=getattr(settings, "debug", False) if settings else False,
        future=True,
    )
    AsyncSessionLocal = sessionmaker(
        bind=engine,
        class_=AsyncSession,
        expire_on_commit=False,
        autoflush=False,
        autocommit=False,
    )

    async def get_db() -> AsyncGenerator[AsyncSession, None]:
        """
        FastAPI dependency (async). Use this when the app runs with an ASYNC URL.
        """
        async with AsyncSessionLocal() as session:
            yield session

else:
    # -------- SYNC engine/session (Alembic) --------
    engine = create_engine(
        DATABASE_URL,
        echo=getattr(settings, "debug", False) if settings else False,
        future=True,
    )
    SessionLocal = sessionmaker(
        bind=engine,
        expire_on_commit=False,
        autoflush=False,
        autocommit=False,
    )

    def get_db() -> Generator:
        """
        Placeholder generator for tooling contexts (like Alembic).
        Your FastAPI app won't use this path because it should run with an ASYNC URL.
        """
        db = SessionLocal()
        try:
            yield db
        finally:
            db.close()
