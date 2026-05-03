# Teman Tuli Monorepo

Single monorepo for Teman Tuli app and API.

## Repository Name
- `teman-tuli`

## Structure
- `apps/teman-tuli-ios`: Teman Tuli iOS app (SwiftUI + Apple Speech)
- `apps/teman-tuli-api`: Teman Tuli API (Fastify + Prisma + PostgreSQL)
- `docs/evidence`: research, SDG mapping, case studies, demo script
- `roadmap-10-weeks.md`: implementation schedule

## Quick Start

### Backend
```bash
cd apps/teman-tuli-api
cp .env.example .env
docker compose up -d
npm install
npm run prisma:generate
npm run prisma:migrate -- --name init
npm run dev
```

### iOS
```bash
cd apps/teman-tuli-ios
xcodegen generate
open TemanTuli.xcodeproj
```
