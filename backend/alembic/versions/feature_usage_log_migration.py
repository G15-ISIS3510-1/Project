"""add feature_usage_log table

Revision ID: feature_usage_log_001
Revises: df48999ddd38
Create Date: 2025-10-30 12:00:00
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = 'feature_usage_log_001'
down_revision = 'df48999ddd38'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table('feature_usage_log',
    sa.Column('id', sa.Integer(), nullable=False, autoincrement=True),
    sa.Column('user_id', sa.String(), nullable=False),
    sa.Column('feature_name', sa.String(length=100), nullable=False),
    sa.Column('timestamp', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
    sa.ForeignKeyConstraint(['user_id'], ['users.user_id'], ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index('ix_feature_usage_log_id', 'feature_usage_log', ['id'], unique=False)
    op.create_index('ix_feature_usage_log_user_id', 'feature_usage_log', ['user_id'], unique=False)
    op.create_index('ix_feature_usage_log_feature_name', 'feature_usage_log', ['feature_name'], unique=False)
    op.create_index('ix_feature_usage_log_timestamp', 'feature_usage_log', ['timestamp'], unique=False)
    op.create_index('ix_feature_usage_log_user_feature', 'feature_usage_log', ['user_id', 'feature_name'], unique=False)


def downgrade() -> None:
    op.drop_index('ix_feature_usage_log_user_feature', table_name='feature_usage_log')
    op.drop_index('ix_feature_usage_log_timestamp', table_name='feature_usage_log')
    op.drop_index('ix_feature_usage_log_feature_name', table_name='feature_usage_log')
    op.drop_index('ix_feature_usage_log_user_id', table_name='feature_usage_log')
    op.drop_index('ix_feature_usage_log_id', table_name='feature_usage_log')
    op.drop_table('feature_usage_log')
