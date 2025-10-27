#!/bin/bash
set -euo pipefail

# Usage:
#   chmod +x deploy_gcp.sh
#   ./deploy_gcp.sh desplieguemoviles us-central1 backend-repo qovo-postgres qovo_db 'P0stgres-Super-Strong-Password!'
#
# Args:
#   1: PROJECT_ID
#   2: REGION
#   3: ARTIFACT_REPO
#   4: SQL_INSTANCE
#   5: SQL_DATABASE
#   6: SQL_PASSWORD

PROJECT_ID=${1:?Provide PROJECT_ID}
REGION=${2:?Provide REGION}
REPO=${3:?Provide ARTIFACT_REPO}
INSTANCE=${4:?Provide SQL_INSTANCE}
DB=${5:?Provide SQL_DATABASE}
DB_PASS=${6:?Provide SQL_PASSWORD}

DB_USER=postgres
IMAGE="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/mobile-backend:latest"
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format='value(projectNumber)')
SERVICE_ACCOUNT="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

echo "==> Configuring gcloud project"
gcloud config set project "$PROJECT_ID"

echo "==> Enabling required services"
gcloud services enable artifactregistry.googleapis.com run.googleapis.com sqladmin.googleapis.com cloudbuild.googleapis.com vpcaccess.googleapis.com

echo "==> Ensuring service account has Cloud SQL Client role"
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${SERVICE_ACCOUNT}" \
  --role="roles/cloudsql.client" >/dev/null

echo "==> Creating Artifact Registry repo (if not exists)"
gcloud artifacts repositories create "$REPO" \
  --repository-format=docker \
  --location="$REGION" \
  --description="Backend images" || true

echo "==> Building and pushing image via Cloud Build"
# Build from the backend folder using absolute path so it works from any CWD
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
gcloud builds submit --tag "$IMAGE" "$SCRIPT_DIR/backend"

echo "==> Creating Cloud SQL Postgres instance (may take a few minutes)"
gcloud sql instances create "$INSTANCE" \
  --database-version=POSTGRES_15 \
  --cpu=1 --memory=4GiB \
  --region="$REGION" \
  --root-password="$DB_PASS" || true

echo "==> Creating database and setting user password"
gcloud sql databases create "$DB" --instance="$INSTANCE" || true
gcloud sql users set-password "$DB_USER" --instance="$INSTANCE" --password="$DB_PASS"

echo "==> Getting INSTANCE_CONNECTION_NAME"
INSTANCE_CONNECTION_NAME=$(gcloud sql instances describe "$INSTANCE" --format="value(connectionName)")
echo "INSTANCE_CONNECTION_NAME=$INSTANCE_CONNECTION_NAME"

echo "==> Creating Cloud Run Job for Alembic migrations"
gcloud run jobs create qovo-migrate \
  --image "$IMAGE" \
  --region "$REGION" \
  --command sh \
  --args -c,"alembic upgrade heads" \
  --set-env-vars DATABASE_URL="postgresql://$DB_USER:$DB_PASS@127.0.0.1:5432/$DB?host=/cloudsql/$INSTANCE_CONNECTION_NAME" \
  --set-cloudsql-instances "$INSTANCE_CONNECTION_NAME" \
  --service-account "$SERVICE_ACCOUNT" \
  --max-retries 0 || true

echo "==> Executing migrations job"
gcloud run jobs execute qovo-migrate --region "$REGION"

echo "==> Deploying API to Cloud Run"
gcloud run deploy qovo-api \
  --image "$IMAGE" \
  --region "$REGION" \
  --allow-unauthenticated \
  --set-env-vars DATABASE_URL="postgresql+asyncpg://$DB_USER:$DB_PASS@127.0.0.1:5432/$DB?host=/cloudsql/$INSTANCE_CONNECTION_NAME" \
  --set-cloudsql-instances "$INSTANCE_CONNECTION_NAME" \
  --service-account "$SERVICE_ACCOUNT" \
  --platform managed \
  --port 8000

echo "==> Done. Fetching service URL"
gcloud run services describe qovo-api --region "$REGION" --format='value(status.url)'


