import os

from app.common.settings import DatabaseSettings, KafkaSettings, load_settings


class Settings(DatabaseSettings, KafkaSettings):
    pass


settings: Settings = load_settings(
    Settings, os.path.join(os.path.dirname(__file__), ".env")
)
