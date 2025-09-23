# FROM python:3.13-slim
# ENV PYTHONUNBUFFERED=True

# # Upgrade pip
# RUN pip install --upgrade pip
# RUN pip install --upgrade pip setuptools wheel

# # Install dependencies
# COPY server/requirements.txt .
# RUN pip install --no-cache-dir -r requirements.txt

# # Set working directory
# ENV APP_HOME=/server
# WORKDIR $APP_HOME

# # Copy application code
# COPY server $APP_HOME

# # Expose Cloud Run port
# EXPOSE 8080

# # Start the app with uvicorn
# CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]

FROM python:3.13-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    APP_HOME=/server

WORKDIR $APP_HOME

# Install OS dependencies including ffmpeg
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc libpq-dev curl ffmpeg \
    && rm -rf /var/lib/apt/lists/*

COPY server/requirements.txt .
RUN pip install --upgrade pip setuptools wheel
RUN pip install --no-cache-dir -r requirements.txt

COPY server/ .

EXPOSE 8080

CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "main:app", \
     "--bind", "0.0.0.0:8080", "--workers", "2", "--threads", "8", "--timeout", "60"]
