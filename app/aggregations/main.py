from app.aggregations.schema import NetworkEventBulkResponse, NetworkEventCreateProposal
from app.aggregations.settings import settings
from app.common.agent import Agent
from app.common.topics import NETWORK_EVENTS
from fastapi import FastAPI

app = FastAPI()
agent = Agent(
    kafka_host=settings.kafka_host,
)


@app.post("/network_events/", response_model=NetworkEventBulkResponse)
async def upload_network_events(records: list[NetworkEventCreateProposal]):
    """
    Submit network events to our data stream
    """
    count = 0
    for i in records:
        await agent.produce(NETWORK_EVENTS, NetworkEventCreateProposal(**i.__dict__))
        count += 1
    return NetworkEventBulkResponse(message="Submitted {count} events", count=count)
