# Microservice

This is a microservice

**Launch Docker Cluster**

This will create local infrastructure (kafka, zookeeper)

```sh
cd docker/
docker-compose up -d
```

**Launch this service**

```sh
uvicorn app.aggregations.main:app --host 0.0.0.0 --port 8000 --reload
```

Service documentation

- OpenAPI: http://localhost:8000/docs
- Redoc: http://localhost:8000/redoc
