FROM python:3.11-slim

WORKDIR /app
COPY . /app

# Only install dependencies available on PyPI
RUN pip install gunicorn

CMD ["gunicorn", "--bind", "0.0.0.0:9000", "app:app"]
