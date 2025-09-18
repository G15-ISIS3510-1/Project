from pydantic import BaseModel, Field
from typing import Optional

# Base schema
class InsurancePlanBase(BaseModel):
    name: str = Field(..., max_length=60, description="Plan name (Basic | Standard | Premium)")
    deductible: float = Field(..., gt=0, description="Deductible amount")
    daily_cost: float = Field(..., gt=0, description="Daily cost of the plan")
    coverage_summary: Optional[str] = Field(None, description="Coverage details")
    active: bool = Field(default=True, description="Is the plan active?")

# Para creación
class InsurancePlanCreate(InsurancePlanBase):
    pass

# Para actualizaciones parciales
class InsurancePlanUpdate(BaseModel):
    name: Optional[str] = Field(None, max_length=60)
    deductible: Optional[float] = Field(None, gt=0)
    daily_cost: Optional[float] = Field(None, gt=0)
    coverage_summary: Optional[str] = None
    active: Optional[bool] = None

# Para respuestas
class InsurancePlanResponse(InsurancePlanBase):
    insurance_plan_id: str

    class Config:
        from_attributes = True
