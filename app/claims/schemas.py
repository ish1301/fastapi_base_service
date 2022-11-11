from pydantic import BaseModel


class ClaimBase(BaseModel):
    name: str
    description: str | None = None
    price: int = 0
    tax: int = 0


class ClaimCreate(ClaimBase):
    pass


class Claim(ClaimBase):
    id: int

    class Config:
        orm_mode = True
