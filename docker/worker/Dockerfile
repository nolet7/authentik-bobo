FROM python:3.11-slim
WORKDIR /worker
COPY . /worker
RUN pip install -r requirements.txt
CMD ["python", "worker.py"]
