#!/bin/bash
# Script para ejecutar migraciones de Alembic en Cloud Run

set -euo pipefail

PROJECT_ID=${1:-desplieguemoviles}
REGION=${2:-us-central1}
INSTANCE=${3:-qovo-postgres}
DB=${4:-qovo_db}
DB_USER=${5:-postgres}
DB_PASS=${6:-"P0stgres-Super-Strong-Password!"}

echo "==> Configuring gcloud project"
gcloud config set project "$PROJECT_ID"

echo "==> Getting INSTANCE_CONNECTION_NAME"
INSTANCE_CONNECTION_NAME=$(gcloud sql instances describe "$INSTANCE" --format="value(connectionName)")
echo "INSTANCE_CONNECTION_NAME=$INSTANCE_CONNECTION_NAME"

PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format='value(projectNumber)')
SERVICE_ACCOUNT="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

IMAGE="${REGION}-docker.pkg.dev/${PROJECT_ID}/backend-repo/mobile-backend:latest"

echo "==> Executing migrations job"
gcloud run jobs execute qovo-migrate \
  --region "$REGION" \
  --wait

echo "==> Migration completed!"

