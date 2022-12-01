from enum import Enum


class EnvironmentName(Enum):
    ENV_DEV = "dev", "Development"
    ENV_STG = "stg", "Stage"
    ENV_PRD = "prd", "Production"
