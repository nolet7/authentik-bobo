# syntax=docker/dockerfile:1

# Stage 1: Build
FROM python:3.11-slim as build

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libffi-dev \
    libpq-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install pipenv or poetry if needed. We'll use pip here for simplicity.
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy application code
COPY . .

# Stage 2: Runtime
FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1
WORKDIR /app

# Copy installed packages and source code
COPY --from=build /usr/local /usr/local
COPY --from=build /app /app

# Expose port
EXPOSE 9000

# Define entrypoint (can be adjusted)
CMD ["gunicorn", "--bind", "0.0.0.0:9000", "authentik_root.asgi:application"]
