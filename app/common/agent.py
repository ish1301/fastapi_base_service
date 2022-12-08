from aiokafka import AIOKafkaConsumer, AIOKafkaProducer

from app.common.base import open_envelope, prepare_envelope
from app.common.events import Event
from app.common.log import get_logger

log = get_logger(__name__)


class Agent:
    def __init__(
        self,
        agent_id,
        kafka_host,
        loop,
    ):
        self.id = agent_id
        self.kafka_host = kafka_host
        self.loop = loop
        self._producer: AIOKafkaProducer = None
        self._consumer: AIOKafkaConsumer = None

    async def produce(
        self,
        topic: str,
        event: Event,
    ):
        if not self._producer:
            p = AIOKafkaProducer(loop=self.loop, bootstrap_servers=self.kafka_host)
            await p.start()
            self._producer = p

        msg = await prepare_envelope(event)
        await self._producer.send(topic, value=msg)
        log.info(f"message sent to topic {topic}")

    async def consume(self, topic: str, func):
        if not self._consumer:
            c = AIOKafkaConsumer(
                topic,
                loop=self.loop,
                bootstrap_servers=self.kafka_host,
                group_id=self.id,
            )
            await c.start()
            self._consumer = c

        async for msg in self._consumer:
            try:
                event = await open_envelope(msg)
                log.debug(f"message received from topic - {topic}")
                await func(event)
            except Exception as e:
                log.exception(e)

    def subscribe(self, topic: str):
        """
        This function reads all events from the provided Kafka topic
        :param topic: topic to read events from
        :return:
        """

        def wrapper(func):
            return self.loop.create_task(self.consume(topic, func))

        return wrapper
