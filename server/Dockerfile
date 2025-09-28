# =========================
# Stage 1: Builder
# =========================
FROM python:3.13-slim AS builder

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    APP_HOME=/server

WORKDIR $APP_HOME

# Install build tools and ffmpeg (needed for building some Python packages)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc libpq-dev curl ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip setuptools wheel
RUN pip install --prefix=/install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# =========================
# Stage 2: Final Image
# =========================
FROM python:3.13-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    APP_HOME=/server

WORKDIR $APP_HOME

# Install runtime OS dependencies (minimal)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev curl ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Copy installed Python packages from builder
COPY --from=builder /install /usr/local

# Copy application code
COPY --from=builder $APP_HOME $APP_HOME

# Expose Cloud Run port
EXPOSE 8080

# Start the app with Gunicorn + Uvicorn worker
CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "main:app", \
     "--bind", "0.0.0.0:8080", "--workers", "2", "--threads", "8", "--timeout", "300"]
