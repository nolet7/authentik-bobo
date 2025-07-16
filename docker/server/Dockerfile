# docker/server/Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Optional: install gunicorn for production server
RUN pip install gunicorn

# Copy your actual application here
COPY . .

CMD ["gunicorn", "main:app", "--bind", "0.0.0.0:9000"]
