# docker/worker/Dockerfile
FROM python:3.11-slim

WORKDIR /worker

# Install Celery without any fake authentik dependency
RUN pip install celery

COPY . .

CMD ["celery", "-A", "main", "worker", "--loglevel=info"]
