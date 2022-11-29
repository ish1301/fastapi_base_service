from app.aggregations.schema import NetworkEventBase, NetworkEventCreate
from fastapi import FastAPI, HTTPException, UploadFile

app = FastAPI()


@app.post("/upload_network_events/", response_model=list[NetworkEventBase])
async def upload_network_events(records: list[NetworkEventCreate]):
    return records
