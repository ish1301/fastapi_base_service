from aiokafka import AIOKafkaConsumer, AIOKafkaProducer

from app.common.base import _open_envelope, _prepare_envelope
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
        self._consumer: AIOKafkaConsumer = None

    async def produce(
        self,
        topic: str,
        event: Event,
    ):
        if not self._producer:
            p = AIOKafkaProducer(bootstrap_servers=self.kafka_host)
            await p.start()
            self._producer = p

        msg = await _prepare_envelope(event)
        log.info(f"Sending message: {event} to topic {topic}")
        await self._producer.send(topic, value=event)
        log.info(f"message sent to topic {topic}")

    async def consume(self, topic: str, func):
        if not self._consumer:
            c = AIOKafkaConsumer(topic, bootstrap_servers=self.kafka_host)
            await c.start()
            self._consumer = c

        async for message_metadata in self.consumer:
            try:
                event = await _open_envelope(message_metadata)
                # log.debug(f"message received post open envelop - {event}")
                await func(event)
            except Exception as e:
                log.exception(e)