import json
from typing import Tuple

from app.common.events import Event


# @TODO, Improve message struct for better performance and storage add event name as meta data
async def prepare_envelope(event):
    return json.dumps(event.__dict__).encode("utf-8")


async def open_envelope(message) -> Tuple[Event, str]:
    return json.loads(message)
