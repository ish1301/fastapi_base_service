FROM python:3.10-alpine

RUN apk update

ENV PYTHONPATH=/code \
  PYTHONFAULTHANDLER=1 \
  PYTHONDONTWRITEBYTECODE=1 \
  PYTHONUNBUFFERED=1

WORKDIR /code

COPY ../requirements.txt ../requirements-dev.txt /code/

RUN pip install --upgrade pip
RUN pip install -r requirements.txt
RUN pip install -r requirements-dev.txt

CMD ["uvicorn", "app.aggregations.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]