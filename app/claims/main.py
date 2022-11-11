from sqlalchemy.orm import Session

from app.claims import crud, models, schemas
from app.claims.database import SessionLocal, engine
from fastapi import Depends, FastAPI

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


@app.post("/claims/", response_model=schemas.Claim)
def create_claim(claim: schemas.ClaimCreate, db: Session = Depends(get_db)):
    return crud.create_claim(db=db, claim=claim)
