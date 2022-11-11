from sqlalchemy.orm import Session

from . import models, schemas


def get_claim(db: Session, claim_id: int):
    return db.query(models.Claim).filter(models.Claim.id == claim_id).first()


def get_claims(db: Session, skip: int = 0, limit: int = 10):
    limit = 100 if limit > 100 else limit
    return db.query(models.Claim).offset(skip).limit(limit).all()


def create_claim(db: Session, claim: schemas.ClaimCreate):
    claimData = {
        "name": claim.name,
        "description": claim.description,
        "price": claim.price,
        "tax": claim.tax,
    }
    print("XXX")
    print(claimData)
    print("XXX")

    db_claim = models.Claim(**claimData)
    db.add(db_claim)
    db.commit()
    db.refresh(db_claim)
    return db_claim
