FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# System dependencies for building wheels and PostgreSQL driver
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libpq-dev curl \
 && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt /app/requirements.txt
RUN pip install --upgrade pip && pip install -r /app/requirements.txt

# Copy backend source code
COPY . /app

# Make entrypoint script executable
RUN chmod +x /app/entrypoint.sh

EXPOSE 8000

# Use entrypoint script to handle PORT variable correctly
ENTRYPOINT ["/app/entrypoint.sh"]


