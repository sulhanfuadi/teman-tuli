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
