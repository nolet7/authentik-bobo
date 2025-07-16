FROM python:3.11-slim

WORKDIR /worker
COPY . /worker

# Example dependency: celery (already available)
RUN pip install celery

CMD ["celery", "-A", "worker.tasks", "worker", "--loglevel=info"]
