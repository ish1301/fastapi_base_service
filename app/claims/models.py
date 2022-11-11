from pydantic import BaseModel


class Claim(BaseModel):
    name: str
    description: str | None = None
    price: float
    tax: float | None = None
