FROM python:3.14-slim AS builder
FROM python:alpine
WORKDIR /app/backend

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY /app ./app
COPY ../VERSION /app/VERSION
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

