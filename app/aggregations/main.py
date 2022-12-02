import asyncio

from app.aggregations.schema import NetworkEventBulkResponse, NetworkEventCreateProposal
from app.aggregations.settings import settings
from app.common import topics
from app.common.agent import Agent
from app.common.events import Event
from fastapi import FastAPI

app = FastAPI()
loop = asyncio.get_event_loop()
agent = Agent(
    kafka_host=settings.kafka_host,
    loop=loop,
)


@app.post("/network_events/", response_model=NetworkEventBulkResponse)
async def upload_network_events(records: list[NetworkEventCreateProposal]):
    """
    Submit network events to our data stream
    """
    count = 0
    for i in records:
        await agent.produce(
            topics.NETWORK_EVENTS, NetworkEventCreateProposal(**i.__dict__)
        )
        count += 1
    return NetworkEventBulkResponse(message="Submitted {count} events", count=count)


@agent.subscribe(topic=topics.NETWORK_EVENTS)
async def handle_network_events(event: Event):
    print(event)
