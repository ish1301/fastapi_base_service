from app.aggregations.schema import NetworkEventBase, NetworkEventCreateProposal
from app.aggregations.settings import settings
from app.common.agent import Agent
from app.common.topics import NETWORK_EVENTS
from fastapi import FastAPI

app = FastAPI()
agent = Agent(
    kafka_host=settings.kafka_host,
)


@app.post("/network_events/", response_model=list[NetworkEventBase])
async def upload_network_events(records: list[NetworkEventCreateProposal]):
    """
    Submit network events to our data stream
    """
    for i in records:
        await agent.produce(NETWORK_EVENTS, NetworkEventCreateProposal(**i.__dict__))
    return records
