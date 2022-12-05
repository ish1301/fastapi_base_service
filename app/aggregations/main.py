import asyncio

from app.aggregations.schema import (
    NetworkEventAggregation,
    NetworkEventBulkResponse,
    NetworkEventCreateProposal,
)
from app.aggregations.settings import settings
from app.common import cache_keys, topics
from app.common.agent import Agent
from app.common.cache import Cache
from app.common.events import Event
from fastapi import FastAPI

app = FastAPI()
loop = asyncio.get_running_loop()
agent = Agent(
    kafka_host=settings.kafka_host,
    loop=loop,
)
cache = Cache()


@app.post("/network_events/bulk_upload", response_model=NetworkEventBulkResponse)
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
    return NetworkEventBulkResponse(message=f"Submitted {count} events", count=count)


@agent.subscribe(topic=topics.NETWORK_EVENTS)
async def handle_network_events(event: Event):
    cache.put(cache_keys.CACHE_NETWORK_EVENTS, event)


@app.get("/network_events/aggregations", response_model=NetworkEventAggregation)
async def upload_network_events():
    return NetworkEventAggregation(uid="", rolling_sum=0, time_diff=0)
