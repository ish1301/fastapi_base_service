import json
from typing import Tuple

from app.common.events import Event

# @TODO, Improve message struct for better performance
# Add EventName as meta data


async def _open_envelope(message) -> Tuple[Event, str]:
    return json.loads(message)


async def _prepare_envelope(event):
    return json.dumps(event.__dict__)
