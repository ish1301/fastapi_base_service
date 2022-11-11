from fastapi import FastAPI

app = FastAPI()


@app.get("/{name}")
async def home(name: str):
    return {"message": "Hello {name}"}
