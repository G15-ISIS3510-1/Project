#!/bin/sh
set -e

# Get port from environment variable, default to 8000
PORT="${PORT:-8000}"

echo "Starting FastAPI application..."
echo "PORT: $PORT"
echo "DATABASE_URL is set: ${DATABASE_URL:+yes}"

# Start uvicorn with the port
exec uvicorn main:app --host 0.0.0.0 --port "$PORT"

