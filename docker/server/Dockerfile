FROM python:3.11-slim

WORKDIR /app
COPY server/ /app

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 9000
CMD ["gunicorn", "--bind", "0.0.0.0:9000", "authentik_root.asgi:application"]
