import asyncio

from app.common import cache_keys, topics
from app.common.agent import Agent
from app.common.cache import Cache
from app.common.events import Event
from app.network_events.schema import (
    NetworkEventAggregation,
    NetworkEventBulkResponse,
    NetworkEventCreateProposal,
)
from app.network_events.settings import settings
from fastapi import FastAPI

app = FastAPI()
loop = asyncio.get_running_loop()
agent = Agent(
    agent_id="network-events",
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
async def network_events_aggregations():
    rolling_sum = 0
    time_diff = 0
    criteria = {}
    events = cache.list(
        cache_keys.CACHE_NETWORK_EVENTS, NetworkEventCreateProposal, criteria
    )
    for e in events:
        rolling_sum += int(e.orig_pkts)

    return NetworkEventAggregation(
        uid="csbodu1e1ve3u0vk98", rolling_sum=rolling_sum, time_diff=time_diff
    )
