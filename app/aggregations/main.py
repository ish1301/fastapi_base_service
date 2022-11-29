from app.aggregations.schema import NetworkEventBase, NetworkEventCreate
from fastapi import FastAPI, HTTPException, UploadFile

app = FastAPI()


@app.post("/network_events/", response_model=list[NetworkEventBase])
async def upload_network_events(records: list[NetworkEventCreate]):
    """
    Submit network events to our data stream
    """
    for i in records:
        print(i)
    return records
