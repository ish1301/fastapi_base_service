import uvicorn

from fastapi import FastAPI

app = FastAPI()


@app.get("/")
async def home():
    return {"message": f"Hello World"}
