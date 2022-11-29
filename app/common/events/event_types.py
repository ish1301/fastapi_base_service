from enum import Enum, unique


@unique
class EventType(Enum):
    UnknownEvent = -1
    Envelope = 0

    # network events
    NetworkEventCreateProposal = 101
    NetworkEventCreateCreated = 105
