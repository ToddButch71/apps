# FROM python:3.13-alpine AS builder
FROM python:3.14.2-alpine AS builder
WORKDIR /app/backend

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app
COPY search_by_serial.py /app/backend/
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

