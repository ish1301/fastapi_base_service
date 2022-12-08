import functools
import uuid
from typing import Type

import sqlalchemy
from sqlalchemy import Column
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import declarative_base, sessionmaker

from app.common.log import get_logger

logger = get_logger(__name__)

Base = declarative_base()


class BaseModel(Base):  # type: ignore
    __abstract__ = True

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)


class Database:
    def __init__(self, database_url: str) -> None:
        super().__init__()
        self.database_url = database_url
        engine = create_async_engine(database_url, echo=False)
        self.async_session = sessionmaker(
            engine, expire_on_commit=False, class_=AsyncSession
        )

    async def get_session(self):
        async with self.async_session() as session:
            async with session.begin():
                yield session

    def transactional(self, func):
        @functools.wraps(func)
        async def wrapper(*args, **kwargs):
            async with self.async_session() as session:
                async with session.begin():
                    logger.info("Starting session in @transactional")
                    result = await func(*args, **kwargs, session=session)
                    await session.commit()

            return result

        return wrapper

    async def get_by_id(self, id: str, cls: Type[BaseModel], session: AsyncSession):
        query = sqlalchemy.select(cls).where(cls.id == id)
        row = await session.execute(query)
        return row.scalars().first()
