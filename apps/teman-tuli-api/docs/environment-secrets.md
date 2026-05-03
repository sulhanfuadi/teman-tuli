# Environment & Secret Hygiene

This document defines deterministic environment setup for development, staging, and production.

## Required Variables (All Environments)
| Variable | Required | Purpose | Notes |
|---|---|---|---|
| `NODE_ENV` | Yes | Runtime mode | `development`, `test`, or `production` |
| `PORT` | Yes | HTTP server port | Default app behavior uses `3000` when unset |
| `DATABASE_URL` | Yes (except test fallback) | PostgreSQL connection | Must point to environment-isolated database |
| `JWT_SECRET` | Yes (except test fallback) | JWT signing key | Minimum 16 chars; use high-entropy random value |

## Environment Profiles

### Development
- Example source: `.env` copied from `.env.example`.
- Expected local DB host: `localhost` via Docker or local PostgreSQL.
- Never use production secrets in local `.env`.

### Staging
- Must use separate DB from development and production.
- `JWT_SECRET` must be unique per environment.
- Store secrets in deployment platform secret manager, not git.

### Production
- Only inject env vars from managed secret store.
- Use least-privileged database credentials.
- Rotate `JWT_SECRET` and DB credentials with controlled rollout.

## Secret Rotation Guidance

### `JWT_SECRET` Rotation
1. Generate new random secret in secret manager.
2. Deploy app with new secret during maintenance window.
3. Force re-authentication window if token invalidation is acceptable.
4. Verify login and protected routes post-rotation.

### `DATABASE_URL` Credential Rotation
1. Create new DB credential with required privileges.
2. Update `DATABASE_URL` in secret manager.
3. Redeploy and validate `/health` + read/write smoke checks.
4. Revoke old credential after verification.

## Guardrails
- Do not hardcode production secrets in source code.
- Do not commit `.env` files.
- Use `npm run prisma:deploy` for migration application in staging/production.
