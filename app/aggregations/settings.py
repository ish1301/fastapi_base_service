import os

from app.common.settings import KafkaSettings, load_settings


class Settings(KafkaSettings):
    pass


settings: Settings = load_settings(
    Settings, os.path.join(os.path.dirname(__file__), ".env")
)
