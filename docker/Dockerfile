FROM python:3.10-alpine

ENV PYTHONPATH=/code \
  PYTHONUNBUFFERED=1

COPY ../ /code

WORKDIR /code

RUN pip install --upgrade pip
RUN pip install -r requirements.txt
RUN pip install -r requirements-dev.txt

CMD ["uvicorn", "app.main:app"]