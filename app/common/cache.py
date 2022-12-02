from typing import List

from mongita.collection import Collection
from mongita.mongita_client import MongitaClientMemory

from app.common.log import get_logger
from app.common.protocols import HasId

log = get_logger(__name__)


class Cache:
    def __init__(self) -> None:
        self.mongita = MongitaClientMemory()
        self.db = self.mongita.db

    def get(self, table: str, cls, entity_id: str):
        collection = self.db[table]
        cached = collection.find_one({"_id": entity_id})
        return cls(**cached) if cached is not None else None

    def list(self, table: str, cls, criteria):
        collection = self.db[table]
        cached = list(collection.find(criteria))
        if not cached:
            return cached
        else:
            doc_list: List = []
            for doc in cached:
                doc_list.append(cls(**doc))
            return doc_list

    def put(self, table: str, obj: HasId):
        collection: Collection = self.db[table]
        _dict = obj.__dict__

        collection.replace_one({"_id": _dict["_id"]}, _dict, upsert=True)
