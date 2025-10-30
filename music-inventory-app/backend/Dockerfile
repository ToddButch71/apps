FROM python:3.11-slim AS builder
# ENV DIRPATH=/Volumes/data/github/apps/music-inventory-app
WORKDIR /app/backend

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY /app ./app
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

