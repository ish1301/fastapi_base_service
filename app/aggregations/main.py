from sqlalchemy.orm import Session

from app.aggregations import crud, models, schemas
from app.common.database import SessionLocal, engine
from fastapi import Depends, FastAPI, UploadFile

app = FastAPI()

models.Base.metadata.create_all(bind=engine)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.get("/claims", response_model=list[schemas.Claim])
async def list_claims(skip: int = 0, limit: str = 10, db: Session = Depends(get_db)):
    claims = crud.get_claims(db, skip=skip, limit=limit)
    return claims


@app.get("/claims/{claim_id}", response_model=schemas.Claim)
async def get_claim(claim_id: int, db: Session = Depends(get_db)):
    claims = crud.get_claim(db, claim_id=claim_id)
    return claims


@app.post("/claims/", response_model=schemas.Claim)
def create_claim(claim: schemas.ClaimCreate, db: Session = Depends(get_db)):
    return crud.create_claim(db=db, claim=claim)


@app.post("/claims_upload/", response_model=list[schemas.Claim])
def upload_claim(file: UploadFile, db: Session = Depends(get_db)):
    return crud.upload_claim(db=db, file=file)
