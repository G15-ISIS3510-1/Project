from sqlalchemy import JSON, Column, Index, String, Integer, Float, DateTime, Boolean, ForeignKey, Enum, Text, UniqueConstraint
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.base import Base
import enum

# Enums
class BookingStatus(str, enum.Enum):
    pending = "pending"
    confirmed = "confirmed"
    active = "active"
    completed = "completed"
    cancelled = "cancelled"

class UserStatus(str, enum.Enum):
    active = "active"
    suspended = "suspended"

class DriverLicenseStatus(str, enum.Enum):
    pending = "pending"
    verified = "verified"

class PaymentStatus(str, enum.Enum):
    authorized = "authorized"
    captured = "captured"
    refunded = "refunded"
    failed = "failed"

# Modelos
class User(Base):
    __tablename__ = "users"
    
    user_id = Column(String, primary_key=True, index=True)
    role = Column(String, nullable=False)  # host | renter | both
    name = Column(String, nullable=False)
    email = Column(String, unique=True, nullable=False, index=True)
    password = Column(String, nullable=False)
    phone = Column(String, nullable=False)
    driver_license_status = Column(Enum(DriverLicenseStatus), default=DriverLicenseStatus.pending)
    status = Column(Enum(UserStatus), default=UserStatus.active)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relaciones
    owned_vehicles = relationship("Vehicle", back_populates="owner")
    renter_bookings = relationship("Booking", back_populates="renter", foreign_keys="Booking.renter_id")
    host_bookings = relationship("Booking", back_populates="host", foreign_keys="Booking.host_id")
    payments = relationship("Payment", back_populates="payer")

    # --- Mensajería ---
    sent_messages = relationship(
        "Message",
        back_populates="sender",
        foreign_keys="Message.sender_id",
        cascade="all, delete-orphan",
        passive_deletes=True,
    )
    received_messages = relationship(
        "Message",
        back_populates="receiver",
        foreign_keys="Message.receiver_id",
        cascade="all, delete-orphan",
        passive_deletes=True,
    )

class Vehicle(Base):
    __tablename__ = "vehicles"
    
    vehicle_id = Column(String, primary_key=True, index=True)
    owner_id = Column(String, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    make = Column(String, nullable=False)
    model = Column(String, nullable=False)
    year = Column(Integer, nullable=False)
    plate = Column(String, unique=True, nullable=False, index=True)
    seats = Column(Integer, nullable=False)
    transmission = Column(String, nullable=False)  # AT/MT/CVT/EV
    fuel_type = Column(String, nullable=False)  # gas/diesel/hybrid/ev
    mileage = Column(Integer, nullable=False)
    status = Column(String, nullable=False)  # active|inactive|pending_review
    lat = Column(Float, nullable=False)  # -90..90
    lng = Column(Float, nullable=False)  # -180..180
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    photo_url = Column(String, nullable=True)
    
    # Relaciones
    owner = relationship("User", back_populates="owned_vehicles")
    availability = relationship("VehicleAvailability", back_populates="vehicle")
    pricing = relationship("Pricing", back_populates="vehicle", uselist=False)
    bookings = relationship("Booking", back_populates="vehicle")

class VehicleAvailability(Base):
    __tablename__ = "vehicle_availability"
    
    availability_id = Column(String, primary_key=True, index=True)
    vehicle_id = Column(String, ForeignKey("vehicles.vehicle_id", ondelete="CASCADE"), nullable=False)
    start_ts = Column(DateTime(timezone=True), nullable=False)
    end_ts = Column(DateTime(timezone=True), nullable=False)
    type = Column(String, nullable=False)  # available|blocked|maintenance
    notes = Column(Text)
    
    # Relaciones
    vehicle = relationship("Vehicle", back_populates="availability")

class Pricing(Base):
    __tablename__ = "pricing"
    
    pricing_id = Column(String, primary_key=True, index=True)
    vehicle_id = Column(String, ForeignKey("vehicles.vehicle_id", ondelete="CASCADE"), unique=True, nullable=False)
    daily_price = Column(Float, nullable=False)
    min_days = Column(Integer, default=1)
    max_days = Column(Integer)
    currency = Column(String, default="USD")
    last_updated = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relaciones
    vehicle = relationship("Vehicle", back_populates="pricing")

class InsurancePlan(Base):
    __tablename__ = "insurance_plans"
    
    insurance_plan_id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    deductible = Column(Float, nullable=False)
    daily_cost = Column(Float, nullable=False)
    coverage_summary = Column(Text, nullable=False)
    active = Column(Boolean, default=True)
    
    # Relaciones
    bookings = relationship("Booking", back_populates="insurance_plan")

class Booking(Base):
    __tablename__ = "bookings"
    
    booking_id = Column(String, primary_key=True, index=True)
    vehicle_id = Column(String, ForeignKey("vehicles.vehicle_id", ondelete="CASCADE"), nullable=False)
    renter_id = Column(String, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    host_id = Column(String, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    insurance_plan_id = Column(String, ForeignKey("insurance_plans.insurance_plan_id"))
    start_ts = Column(DateTime(timezone=True), nullable=False)
    end_ts = Column(DateTime(timezone=True), nullable=False)
    status = Column(Enum(BookingStatus), default=BookingStatus.pending)
    
    # Snapshots económicos
    daily_price_snapshot = Column(Float, nullable=False)
    insurance_daily_cost_snapshot = Column(Float)
    subtotal = Column(Float, nullable=False)
    fees = Column(Float, default=0)
    taxes = Column(Float, default=0)
    total = Column(Float, nullable=False)
    currency = Column(String, default="USD")
    
    # Estado del vehículo
    odo_start = Column(Integer)
    odo_end = Column(Integer)
    fuel_start = Column(Integer)  # 0-100
    fuel_end = Column(Integer)  # 0-100
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relaciones
    vehicle = relationship("Vehicle", back_populates="bookings")
    renter = relationship("User", back_populates="renter_bookings", foreign_keys=[renter_id])
    host = relationship("User", back_populates="host_bookings", foreign_keys=[host_id])
    insurance_plan = relationship("InsurancePlan", back_populates="bookings")
    payments = relationship("Payment", back_populates="booking")

class Payment(Base):
    __tablename__ = "payments"
    
    payment_id = Column(String, primary_key=True, index=True)
    booking_id = Column(String, ForeignKey("bookings.booking_id", ondelete="CASCADE"), nullable=False)
    payer_id = Column(String, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    amount = Column(Float, nullable=False)
    currency = Column(String, default="USD")
    status = Column(Enum(PaymentStatus), nullable=False)
    provider = Column(String, nullable=False)  # ej. stripe, adyen
    provider_ref = Column(String)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relaciones
    booking = relationship("Booking", back_populates="payments")
    payer = relationship("User", back_populates="payments")

class Message(Base):
    __tablename__ = "messages"

    message_id = Column(String, primary_key=True, index=True)
    sender_id = Column(String, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False, index=True)
    receiver_id = Column(String, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False, index=True)

    content = Column(Text, nullable=False)

    # 👇 Agrega el FK real a conversations; deja SET NULL si borran la conversación
    conversation_id = Column(
        String,
        ForeignKey("conversations.conversation_id", ondelete="SET NULL"),
        nullable=True,
        index=True,
    )

    meta = Column("metadata", JSON, nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False, index=True)
    read_at = Column(DateTime(timezone=True), nullable=True, index=True)

    # Relaciones
    sender = relationship("User", back_populates="sent_messages", foreign_keys=[sender_id])
    receiver = relationship("User", back_populates="received_messages", foreign_keys=[receiver_id])

    # 👇 Relación inversa con Conversation
    conversation = relationship("Conversation", back_populates="messages")

    __table_args__ = (
        Index("ix_messages_thread_order", "sender_id", "receiver_id", "created_at"),
        Index("ix_messages_unread", "receiver_id", "read_at"),
    )

class Conversation(Base):
    __tablename__ = "conversations"

    conversation_id = Column(String, primary_key=True, index=True)
    user_low_id = Column(String, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False, index=True)
    user_high_id = Column(String, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False, index=True)
    title = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    last_message_at = Column(DateTime(timezone=True), nullable=True, index=True)

    # 👇 relación clara con back_populates (sin primaryjoin manual)
    messages = relationship("Message", back_populates="conversation")

    __table_args__ = (
        UniqueConstraint("user_low_id", "user_high_id", name="uq_conversation_direct_pair"),
        Index("ix_conversations_user_pair", "user_low_id", "user_high_id"),
        Index("ix_conversations_last_message_at", "last_message_at"),
    )