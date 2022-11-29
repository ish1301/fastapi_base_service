from fastapi import FastAPI, UploadFile

app = FastAPI()


@app.post("/upload_network_events/")
async def upload_network_events(file: UploadFile()):
    return {"filename": file.filename}
