import uvicorn

from fastapi import FastAPI

app = FastAPI()


@app.get("/claims")
async def get_claims():
    return {"message": f"Hello World"}
