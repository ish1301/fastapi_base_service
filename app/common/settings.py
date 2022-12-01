import os
from typing import Optional

from pydantic import BaseSettings

from app.common.enums import EnvironmentName
from app.common.log import get_logger

log = get_logger(__name__)


class ESBaseSettings(BaseSettings):
    env: str = EnvironmentName.ENV_DEV.value

    def get(self, *args):
        values = []
        for key in args:
            if not hasattr(self, key):
                values.append(None)
                continue
            values.append(getattr(self, key))
        return tuple(values)


class DatabaseSettings(ESBaseSettings):
    db_driver: str = "postgresql+asyncpg"
    db_host: str = "localhost"
    db_port: str = "5432"
    db_user: str = "admin"
    db_pass: str = "password"
    database_debug: bool = False

    def db_url(self, db_name):
        return f"{self.db_driver}://{self.db_user}:{self.db_pass}@{self.db_host}:{self.db_port}/{db_name}"


class KafkaSettings(ESBaseSettings):
    kafka_host: str = "127.0.0.1:9092"


def load_settings(cls, env_file):
    if env_file and os.path.exists(env_file):
        log.info(f"Loading configuration from {env_file} file")
        settings = cls(_env_file=env_file, _env_file_encoding="utf-8")
    else:
        log.info("Loading configuration from ENV")
        settings = cls()

    for attr in vars(settings).items():
        # avoid logging sensitive data
        if attr[0] in ("db_pass", "db_user", "mutual_tls_key"):
            log.info(f"{attr[0]} :: *********")
        else:
            log.info(f"{attr[0]} :: {attr[1]}")
    return settings
