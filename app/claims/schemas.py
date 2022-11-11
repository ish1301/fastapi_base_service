from pydantic import BaseModel


class ClaimBase(BaseModel):
    name: str
    description: str | None = None
    price: float = 0
    tax: float = 0


class ClaimCreate(ClaimBase):
    pass


class Claim(ClaimBase):
    id: int

    class Config:
        orm_mode = True
