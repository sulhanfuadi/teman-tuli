# Teman Tuli

An accessibility-first app that helps Deaf students follow fast classroom discussions using live captions and private transcript sessions.

## Problem
Many Deaf and hard-of-hearing students lose context in class when:
- speaking pace is too fast,
- interpreters are unavailable,
- shared notes are incomplete or late,
- important points are discussed spontaneously.

This directly affects learning quality, confidence, and participation.

## User Research Snapshot
Research direction is documented in `docs/evidence/research` and is centered on real classroom barriers.

Key interview themes:
- students need **immediate caption visibility**, not delayed notes,
- text must be **large, readable, and stable** during discussion,
- transcript data can contain sensitive classroom content,
- users want full control over when transcript data is saved.

Design decisions from research:
- live caption is the primary screen,
- transcript upload is explicit (`Simpan Privat`) and never automatic,
- archived sessions are private by default.

## SDG Alignment
Teman Tuli is aligned with:
- **SDG 4 — Quality Education**: improves access to classroom content,
- **SDG 10 — Reduced Inequalities**: reduces communication barriers for Deaf students,
- **SDG 3 — Good Health and Well-being** (secondary): reduces stress from missing core learning context.

## Solution Overview
Teman Tuli provides a simple accessibility loop:
1. Start live caption in class,
2. Read captions in a high-visibility interface,
3. Stop and save transcript only when user chooses,
4. Revisit private transcript sessions, add notes, and submit caption-quality feedback.

## Core Features
### iOS App (`apps/teman-tuli-ios`)
- Onboarding and authentication flow
- Live caption using Apple Speech framework
- Private transcript save flow with explicit user action
- Transcript archive and session detail view
- Personal notes and caption feedback submission

### Backend API (`apps/teman-tuli-api`)
- JWT auth endpoints
- Private transcript session CRUD
- Timestamped transcript segments
- Caption feedback endpoint for iteration evidence
- Versioned routes under `/api/v1`

## Privacy Principles
- Private by default
- No automatic transcript upload during live captioning
- User-scoped access to saved sessions
- Explicit save action before any backend persistence

## Tech Stack
- **iOS**: SwiftUI, MVVM, Speech, AVFoundation
- **Backend**: Fastify, TypeScript, Prisma, PostgreSQL
- **Docs/Research**: Markdown evidence pack for iteration and case-study storytelling

## Repository Structure
- `apps/teman-tuli-ios` — iOS client
- `apps/teman-tuli-api` — backend API
- `docs/evidence` — research, case studies, scripts, iteration logs
- `docs/roadmap-10-weeks.md` — implementation roadmap
- `AGENTS.md` — repository working instructions for coding agents

## Quick Start
### Backend API
```bash
cd apps/teman-tuli-api
cp .env.example .env
docker compose up -d
npm install
npm run prisma:generate
npm run prisma:migrate -- --name init
npm run dev
```

### iOS App
```bash
cd apps/teman-tuli-ios
xcodegen generate
open TemanTuli.xcodeproj
```

## Validation
Backend validation commands:
```bash
cd apps/teman-tuli-api
npm test
npm run build
```

## Documentation
- Research & evidence: `docs/evidence/README.md`
- Product roadmap: `docs/roadmap-10-weeks.md`
