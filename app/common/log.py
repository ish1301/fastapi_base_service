import logging.config
import os


def get_logger(name: str):
    logging.config.fileConfig(
        os.path.join(os.path.dirname(__file__), "logging.conf"),
        disable_existing_loggers=False,
    )
    return logging.getLogger(name)
