import codecs
import csv

from sqlalchemy.orm import Session

from . import models, schemas


def get_claim(db: Session, claim_id: int):
    return db.query(models.Claim).filter(models.Claim.id == claim_id).first()


def get_claims(db: Session, skip: int = 0, limit: int = 10):
    limit = 100 if limit > 100 else limit
    return db.query(models.Claim).offset(skip).limit(limit).all()


def create_claim(db: Session, claim: schemas.ClaimCreate):
    db_claim = models.Claim(**claim.dict())
    db.add(db_claim)
    db.commit()
    db.refresh(db_claim)
    return db_claim


def upload_claim(db: Session, file: schemas.ClaimFileUpload):
    def clean_label(head):
        for i in ["\n", "#", "/", "  "]:
            head = head.replace(i, " ").strip()

        return head.lower().replace(" ", "_")

    claims = []
    csvReader = csv.reader(codecs.iterdecode(file.file, "utf-8"))
    headers = [clean_label(i) for i in next(csvReader)]

    for row in csvReader:
        claimData = {i: j for i, j in zip(headers, row)}

        db_claim = models.Claim(**claimData)
        db.add(db_claim)
        print(claimData)

    db.commit()
    db.refresh(db_claim)

    return claims
