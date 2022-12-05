# Microservice

This is a microservice template design by Ish Kumar <ish1301@gmail.com>

**Launch Docker Cluster**

This will create local infrastructure (kafka, zookeeper)

```sh
cd docker/
docker-compose up -d
```

**Setup Local Virtual Environment**

```sh
python -m venv venv
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

**Launch Service Locally**

```sh
. venv/bin/activate
uvicorn app.aggregations.main:app --host 0.0.0.0 --port 8000 --reload
```

Service documentation

- OpenAPI: http://localhost:8000/docs
- Redoc: http://localhost:8000/redoc
