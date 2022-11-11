import uvicorn

from fastapi import FastAPI

app = FastAPI()


@app.get("/{name}")
async def home(name: str):
    return {"message": "Hello {name}"}


if __name__ == "__main__":
    uvicorn.run("app:main", host="127.0.0.1", port=6000, reload=True)
