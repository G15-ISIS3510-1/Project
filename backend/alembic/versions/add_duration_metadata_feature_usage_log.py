"""add duration and metadata columns to feature usage log

Revision ID: add_duration_metadata_feature_usage_log
Revises: feature_usage_log_001
Create Date: 2025-11-27 00:00:00
"""

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'add_duration_metadata_feature_usage_log'
down_revision = 'feature_usage_log_001'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column('feature_usage_log', sa.Column('duration_seconds', sa.Float(), nullable=True))
    op.add_column('feature_usage_log', sa.Column('metadata', sa.JSON(), nullable=True))


def downgrade() -> None:
    op.drop_column('feature_usage_log', 'metadata')
    op.drop_column('feature_usage_log', 'duration_seconds')

