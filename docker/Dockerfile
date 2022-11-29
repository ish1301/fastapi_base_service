FROM python:3.10-alpine

ENV PYTHONPATH=/code \
  PYTHONFAULTHANDLER=1 \
  PYTHONUNBUFFERED=1

WORKDIR /code

COPY requirements.txt requirements-dev.txt /code/

RUN pip install -r requirements.txt
RUN pip install -r requirements-dev.txt
