from sqlalchemy.ext.asyncio import AsyncSession
from app.schemas.booking import BookingCreate, BookingUpdate
from app.db.models import Booking

class BookingService:
    def _init_(self, db: AsyncSession ):
        self.db =db

    # CREATE
    async def create_booking(self, booking_data: BookingCreate) -> Booking:
        pass

    # GET
    async def get_booking(self):
        pass

    async def get_bookings(self):
        pass


    async def get_booking_by_id_vehicle(self):
        pass

    async def get_bookings_by_id_vehicle(self):
        pass


    async def get_booking_by_id_user(self):
        pass

    async def get_bookings_by_id_user(self):
        pass

    async def get_booking_by_id_insurance_plan(self):
        pass

    async def get_bookings_by_id_insurance_plan(self):
        pass


    # UPDATE

    async def update_booking(self):
        pass

    async def update_booking_by_id_vehicle(self):
        pass

    async def update_booking_by_id_user(self):
        pass

    async def update_booking_by_id_insurance_plan(self):
        pass

    # DELETE

    async def delete_booking(self):
        pass

    async def delete_booking_by_id_vehicle(self):
        pass

    async def delete_booking_by_id_user(self):
        pass

    async def delete_booking_by_id_insurance_plan(self):
        pass



