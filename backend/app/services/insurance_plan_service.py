
from sqlalchemy.ext.asyncio import AsyncSession
from app.schemas.insurance_plan import InsurancePlanCreate, InsurancePlanUpdate
from app.db.models import InsurancePlan, Booking

class InsurancePlanService:
    def _init_(self, db: AsyncSession ):
        self.db =db

    # CREATE
    async def create_insurance_plan(self, insurance_plan_data: InsurancePlanCreate) -> InsurancePlan:
        pass


    # GET
    async def get_insurance_plan(self):
        pass

    async def get_insurance_plans(self):
        pass

    async def get_insurance_plan_by_id_booking(self):
        pass

    async def get_insurance_plans_by_id_booking(self):
        pass

    # UPDATE
    async def update_insurance_plan(self):
        pass

    async def update_insurance_plan_by_id_booking(self):
        pass

    # DELETE
    async def delete_insurance_plan(self):
        pass

    async def delete_insurance_plan_by_id_booking(self):
        pass

