FROM python:3.10-alpine

ENV PYTHONPATH=/code \
  PYTHONUNBUFFERED=1

COPY . /code

WORKDIR /code

RUN pip install -r requirements.txt

CMD ["uvicorn", "app.main:app"]