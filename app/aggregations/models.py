from sqlalchemy import Column, Float, Integer, String

from ..common.database import Base


class Claim(Base):
    __tablename__ = "claims"

    id = Column(Integer, primary_key=True, index=True)
    service_date = Column(String, nullable=True)
    submitted_procedure = Column(String, nullable=True)
    quadrant = Column(String, nullable=True)
    plan_group = Column(String, nullable=True)
    subscriber = Column(String, nullable=True)
    provider_npi = Column(String, nullable=True)
    provider_fees = Column(String, nullable=True)
    allowed_fees = Column(String, nullable=True)
    member_coinsurance = Column(String, nullable=True)
    member_copay = Column(String, nullable=True)
