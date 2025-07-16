# docker/server/Dockerfile

FROM python:3.11-slim

WORKDIR /app

COPY . .

RUN pip install -r requirements.txt

EXPOSE 9000

CMD ["gunicorn", "--bind", "0.0.0.0:9000", "authentik_root.asgi:application"]
