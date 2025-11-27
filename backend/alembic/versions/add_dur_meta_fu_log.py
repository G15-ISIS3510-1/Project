"""add duration and metadata columns to feature usage log

Revision ID: add_dur_meta_fu_log
Revises: feature_usage_log_001
Create Date: 2025-11-27 00:00:00
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql


# revision identifiers, used by Alembic.
revision = 'add_dur_meta_fu_log'
down_revision = 'feature_usage_log_001'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column('feature_usage_log', sa.Column('duration_seconds', sa.Float(), nullable=True))
    op.add_column('feature_usage_log', sa.Column('metadata', postgresql.JSON(astext_type=sa.Text()), nullable=True))


def downgrade() -> None:
    op.drop_column('feature_usage_log', 'metadata')
    op.drop_column('feature_usage_log', 'duration_seconds')

