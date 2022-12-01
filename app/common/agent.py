from aiokafka import AIOKafkaProducer

from app.common.events import Event
from app.common.log import get_logger

log = get_logger(__name__)


class Agent:
    def __init__(
        self,
        kafka_host,
    ):
        self.kafka_host = kafka_host
        self._producer: AIOKafkaProducer = None

    async def produce(
        self,
        topic: str,
        event: Event,
    ):
        if not self._producer:
            p = AIOKafkaProducer(bootstrap_servers=self.kafka_host)
            await p.start()
            self._producer = p

        log.info(f"Sending message: {event} to topic {topic}")
        await self._producer.send(topic, value=event)
        log.info(f"message sent to topic {topic}")

    async def produce_and_wait(
        self,
        topic: str,
        event: Event,
    ):
        if not self._producer:
            p = AIOKafkaProducer(bootstrap_servers=self.kafka_host)
            await p.start()
            self._producer = p

        log.info(f"Sending message: {event} to topic {topic}")
        await self._producer.send_and_wait(topic, value=event)
        log.info(f"message sent to topic {topic}")
