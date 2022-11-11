import uvicorn


from fastapi import FastAPI
from app.claims import crud, models, schemas
from app.claims.database import SessionLocal, engine

app = FastAPI()

models.Base.metadata.create_all(bind=engine)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.get("/claims")
async def get_claims():
    return []
