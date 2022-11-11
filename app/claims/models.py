from sqlalchemy import Column, Integer, String, Float

from .database import Base


class Claim(Base):
    __tablename__ = "claims"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    description = Column(String, nullable=True)
    price: Column(Float, default=0)
    tax: Column(Float, default=0)
