# --- config ---
$DB_HOST="127.0.0.1"; $DB_PORT="55432"; $DB_USER="postgres"; $DB_PASS="postgres"; $DB_NAME="postgres"
$SEED_EMAIL="admin@example.com"; $SEED_PASSWORD="supersecret"
$API="http://127.0.0.1:8000"

# --- env ---
$env:PYTHONPATH = "$PWD"
$env:PYTHON_DOTENV_DISABLE = "1"
$env:DATABASE_URL       = "postgresql://$DB_USER`:$DB_PASS@$DB_HOST`:$DB_PORT/$DB_NAME"           # SYNC for alembic
$env:DATABASE_URL_ASYNC = "postgresql+asyncpg://$DB_USER`:$DB_PASS@$DB_HOST`:$DB_PORT/$DB_NAME"   # ASYNC for app
$env:SEED_EMAIL         = $SEED_EMAIL
$env:SEED_PASSWORD      = $SEED_PASSWORD
$env:SEED_BASE_URL      = $API

# --- migrate ---
alembic upgrade head   # <-- use CLI; NOT "python -m alembic"

# --- start API in background (async URL) ---
$env:DATABASE_URL = $env:DATABASE_URL_ASYNC
$apiJob = Start-Job { param($pwd) Set-Location $pwd; uvicorn main:app --reload } -ArgumentList $PWD

# --- wait for API to be up ---
$live=$false; 1..60 | ForEach-Object {
  try { if ((Invoke-WebRequest "$API/docs" -UseBasicParsing -TimeoutSec 2).StatusCode -ge 200) { $live=$true; break } }
  catch { Start-Sleep -Milliseconds 500 }
}
if (-not $live) { Stop-Job $apiJob; Receive-Job $apiJob -Keep; throw "API did not start" }

# --- seed everything ---
python -m seed_data.seed_all

# --- stop API ---
Stop-Job $apiJob | Out-Null
Receive-Job $apiJob -Keep | Out-Null
Write-Host "Seeding complete."
