# AGENTS.md

This file defines working instructions for coding agents in this repository.

## Scope
- These instructions apply to the entire repository tree rooted at this folder.

## Project Goal
- Build and maintain **Teman Tuli**, an accessibility-first app for Deaf students.
- Keep the product focused on:
  - live classroom captions on iOS,
  - private transcript archiving,
  - simple and reliable end-to-end behavior.

## Repository Structure
- `apps/teman-tuli-ios` — iOS app (SwiftUI + Speech framework).
- `apps/teman-tuli-api` — backend API (Fastify + Prisma + PostgreSQL).
- `docs/evidence` — research notes, case studies, and demo material.
- `docs/roadmap-10-weeks.md` — execution roadmap.

## Implementation Rules
- Keep changes minimal and scoped to the user request.
- Do not add new major dependencies unless clearly required.
- Prefer readability and maintainability over clever shortcuts.
- Keep transcript privacy defaults intact (private-by-default, explicit save).
- Preserve API versioning under `/api/v1`.

## Testing and Validation
- Backend changes should pass:
  - `cd apps/teman-tuli-api && npm test`
  - `cd apps/teman-tuli-api && npm run build`
- For iOS changes, keep code compilable and XcodeGen-compatible.

## Documentation Style
- Write repository-facing docs in English.
- Update docs when behavior, paths, commands, or architecture changes.

## Out of Scope (unless explicitly requested)
- Creating CI/CD pipelines.
- Publishing to App Store/TestFlight.
- Infra provisioning beyond local Docker/Postgres.
