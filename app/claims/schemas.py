from pydantic import BaseModel


class ClaimBase(BaseModel):
    service_date: str | None = None
    submitted_procedure: str | None = None
    quadrant: str | None = None
    plan_group: str | None = None
    subscriber: str | None = None
    provider_npi: str | None = None
    provider_fees: str | None = None
    allowed_fees: str | None = None
    member_coinsurance: str | None = None
    member_copay: str | None = None


class ClaimCreate(ClaimBase):
    pass


class Claim(ClaimBase):
    id: int

    class Config:
        orm_mode = True


class ClaimFileUpload(BaseModel):
    fileame: str
