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
    return []
