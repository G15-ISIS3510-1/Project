# backend/alembic/env.py

from logging.config import fileConfig
import os
import sys

from sqlalchemy import create_engine, pool
from alembic import context

# --- Make sure Alembic can import your application package ---
# This file lives at .../backend/alembic/env.py
# Add the backend/ directory to sys.path so "app" is importable.
_THIS_DIR = os.path.dirname(os.path.abspath(__file__))          # .../backend/alembic
_PROJECT_ROOT = os.path.abspath(os.path.join(_THIS_DIR, ".."))  # .../backend
if _PROJECT_ROOT not in sys.path:
    sys.path.insert(0, _PROJECT_ROOT)

# Now we can import your models and settings
from app.db.models import Base
from app.core.config import settings

# The Alembic Config object, providing access to .ini values etc.
config = context.config

# Configure logging from alembic.ini
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# Use the env var DATABASE_URL if set; otherwise fall back to settings.database_url
# (Important so you can point Alembic at 127.0.0.1:55432 when running locally.)
DB_URL = os.environ.get("DATABASE_URL", settings.database_url)

# Also write it into the alembic config so other helpers read the same value
if DB_URL:
    config.set_main_option("sqlalchemy.url", DB_URL)

# Tell Alembic what metadata to autogenerate from
target_metadata = Base.metadata


def run_migrations_offline() -> None:
    """
    Run migrations in 'offline' mode (no Engine).
    """
    url = config.get_main_option("sqlalchemy.url") or DB_URL
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        compare_type=True,             # detect column type changes
        compare_server_default=True,   # detect server_default changes
    )

    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    """
    Run migrations in 'online' mode (with Engine/Connection).
    """
    url = config.get_main_option("sqlalchemy.url") or DB_URL
    connectable = create_engine(
        url,
        poolclass=pool.NullPool,
        future=True,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
            compare_type=True,
            compare_server_default=True,
        )

        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
