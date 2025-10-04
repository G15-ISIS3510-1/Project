
"""${message}

Revision ID: ${up_revision}
Revises: ${down_revision | comma,n}
Create Date: ${create_date}

"""

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = '46698da4d29a'
down_revision = 'edf723e2131e'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Create vehicle_ratings table without foreign keys first
    op.create_table('vehicle_ratings',
        sa.Column('rating_id', sa.String(), nullable=False),
        sa.Column('vehicle_id', sa.String(), nullable=False),
        sa.Column('booking_id', sa.String(), nullable=False),
        sa.Column('renter_id', sa.String(), nullable=False),
        sa.Column('rating', sa.Float(), nullable=False),
        sa.Column('comment', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=True),
        sa.PrimaryKeyConstraint('rating_id')
    )
    
    # Create indexes
    op.create_index(op.f('ix_vehicle_ratings_rating_id'), 'vehicle_ratings', ['rating_id'], unique=False)
    op.create_index(op.f('ix_vehicle_ratings_vehicle_id'), 'vehicle_ratings', ['vehicle_id'], unique=False)
    op.create_index(op.f('ix_vehicle_ratings_booking_id'), 'vehicle_ratings', ['booking_id'], unique=False)
    op.create_index(op.f('ix_vehicle_ratings_renter_id'), 'vehicle_ratings', ['renter_id'], unique=False)
    op.create_index('ix_vehicle_ratings_vehicle_rating', 'vehicle_ratings', ['vehicle_id', 'rating'], unique=False)
    op.create_index('ix_vehicle_ratings_renter_booking', 'vehicle_ratings', ['renter_id', 'booking_id'], unique=False)


def downgrade() -> None:
    # Drop indexes
    op.drop_index('ix_vehicle_ratings_renter_booking', table_name='vehicle_ratings')
    op.drop_index('ix_vehicle_ratings_vehicle_rating', table_name='vehicle_ratings')
    op.drop_index(op.f('ix_vehicle_ratings_renter_id'), table_name='vehicle_ratings')
    op.drop_index(op.f('ix_vehicle_ratings_booking_id'), table_name='vehicle_ratings')
    op.drop_index(op.f('ix_vehicle_ratings_vehicle_id'), table_name='vehicle_ratings')
    op.drop_index(op.f('ix_vehicle_ratings_rating_id'), table_name='vehicle_ratings')
    
    # Drop table
    op.drop_table('vehicle_ratings')
