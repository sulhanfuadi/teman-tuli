# Teman Tuli Backend (`apps/teman-tuli-api`)

Backend API for **Teman Tuli**, an accessibility-first application project for Mahasiswa Tuli.

## Problem
Mahasiswa Tuli can miss important context during fast classroom discussions, especially when captions, interpreters, or accessible notes are unavailable.

## Solution
A privacy-first REST API that supports:
- account onboarding
- private transcript session archive
- transcript segments with timestamps
- optional notes per class session
- caption quality feedback for iteration evidence

## Architecture
- Node.js + TypeScript + Fastify
- Prisma ORM + PostgreSQL
- JWT authentication
- OpenAPI docs (`/docs` and `docs/openapi.yaml`)

## API (v1)

Baseline migration is commit-tracked in `prisma/migrations/0001_init`.

Base path: `/api/v1`
- `POST /auth/register`
- `POST /auth/login`
- `GET /sessions`
- `POST /sessions`
- `GET /sessions/:id`
- `PATCH /sessions/:id`
- `DELETE /sessions/:id`
- `POST /sessions/:id/feedback`

## Privacy Defaults
- Transcripts are private by default.
- Sessions are scoped to the authenticated user.
- Live caption text is uploaded only after the user explicitly saves a session.

## Setup
1. Copy env file:
   ```bash
   cp .env.example .env
   ```
2. Start PostgreSQL:
   ```bash
   docker compose up -d
   ```
3. Install deps:
   ```bash
   npm install
   ```
4. Generate Prisma client + apply committed baseline migration:
   ```bash
   npm run prisma:generate
   npm run prisma:deploy
   ```

5. If you change schema locally later, create a new migration with:
   ```bash
   npm run prisma:migrate -- --name <change_name>
   ```
6. Start dev server:
   ```bash
   npm run dev
   ```

Environment and secret policy is documented in:
- `docs/environment-secrets.md`

## Migration Reproducibility Check (Priority 0.2)
Use this sequence to verify clean-database bootstrap from committed migration files only.

### Preconditions
- Docker is installed and available in PATH.
- `.env` has valid `DATABASE_URL` and `JWT_SECRET`.

### Clean Bootstrap Sequence
```bash
docker compose down -v
docker compose up -d
npm install
npm run prisma:generate
npm run prisma:deploy
```

Expected migration output should include these indicators:
- `Prisma schema loaded from prisma/schema.prisma`
- `Datasource "db": PostgreSQL database "teman_tuli"`
- `1 migration found in prisma/migrations`
- `The following migration(s) have been applied:`
- `0001_init`
- `All migrations have been successfully applied.`

### API Boot Check (No ad-hoc schema drift)
Start API immediately after `prisma:deploy` without `prisma migrate dev`:

```bash
npm run dev
```

In a second terminal:

```bash
curl http://localhost:3000/health
```

Expected response:

```json
{"ok":true,"service":"teman-tuli-backend"}
```

### Drift Guard Rule
- Production-like bootstrap must only use committed migrations via `npm run prisma:deploy`.
- Do not rely on local-only schema changes or `prisma db push`.

### Local Verification Evidence (2026-05-03)
- `npm run prisma:deploy` was executed in this workspace and failed at schema engine stage because local PostgreSQL service was unavailable.
- `docker` command is not installed in this runtime, so clean DB reset could not be executed here.
- Backend quality gate still passed locally:
  - `npm test` ✅
  - `npm run build` ✅

## Testing
```bash
npm test
```

## Tradeoffs
- v1 uses private archives instead of public sharing to avoid classroom privacy risks.
- Caption generation happens on-device in the iOS app; backend stores only user-approved saved sessions.

## Future Scope
- Share-by-class-code with explicit consent.
- Lecturer summary export.
- Human correction workflow for important transcripts.
