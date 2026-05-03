#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v docker >/dev/null 2>&1; then
  echo "[P0.2] ERROR: docker not found in PATH"
  echo "Install Docker Desktop first, then re-run this script."
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "[P0.2] ERROR: docker compose not available"
  exit 1
fi

if [ ! -f .env ]; then
  echo "[P0.2] ERROR: .env not found. Run: cp .env.example .env"
  exit 1
fi

echo "[P0.2] Resetting DB container volume"
docker compose down -v

echo "[P0.2] Starting PostgreSQL"
docker compose up -d

echo "[P0.2] Installing dependencies"
npm ci

echo "[P0.2] Generating Prisma client"
npm run prisma:generate

echo "[P0.2] Applying committed migrations only"
set +e
DEPLOY_OUTPUT="$(npm run prisma:deploy 2>&1)"
DEPLOY_STATUS=$?
set -e

echo "$DEPLOY_OUTPUT"

if [ $DEPLOY_STATUS -ne 0 ]; then
  echo "[P0.2] ERROR: prisma:deploy failed"
  exit $DEPLOY_STATUS
fi

echo "$DEPLOY_OUTPUT" | grep -q "Prisma schema loaded from prisma/schema.prisma"
echo "$DEPLOY_OUTPUT" | grep -q "Datasource \"db\": PostgreSQL database \"teman_tuli\""
echo "$DEPLOY_OUTPUT" | grep -q "0001_init"

echo "[P0.2] Booting API for health check"
npm run dev >/tmp/teman-tuli-api-dev.log 2>&1 &
API_PID=$!
trap 'kill $API_PID >/dev/null 2>&1 || true' EXIT

sleep 5

set +e
HEALTH_BODY="$(curl -sS http://localhost:3000/health)"
HEALTH_STATUS=$?
set -e

if [ $HEALTH_STATUS -ne 0 ]; then
  echo "[P0.2] ERROR: /health check failed"
  echo "See /tmp/teman-tuli-api-dev.log for server logs"
  exit 1
fi

echo "[P0.2] /health response: $HEALTH_BODY"

echo "$HEALTH_BODY" | grep -q '"ok":true'

echo "[P0.2] SUCCESS: clean DB bootstrap and API run verified"
