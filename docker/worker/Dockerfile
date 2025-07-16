FROM python:3.11-slim

WORKDIR /worker
COPY worker/ /worker

RUN pip install --no-cache-dir -r requirements.txt

CMD ["celery", "-A", "worker.tasks", "worker", "--loglevel=info"]
