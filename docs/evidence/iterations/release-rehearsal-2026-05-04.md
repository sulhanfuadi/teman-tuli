# Release Rehearsal Evidence — 2026-05-04

## Scope
Rehearsal execution for `docs/release-runbook.md` with local environment parity checks.

## Environment
- Date: `2026-05-04`
- Executor: Codex CLI + local runtime
- Target: `apps/teman-tuli-api`
- Runtime mode: local Docker + Node 22 + Prisma migrate deploy

## Commands Executed
```bash
cd apps/teman-tuli-api
npm test
npm run build
bash scripts/verify-p0.2-migration-repro.sh
```

## Pre-Flight Checklist Result
- [x] PR-equivalent quality gate green (`npm test`, `npm run build`)
- [x] Target branch state and working tree verified before rehearsal
- [x] Required env vars available for local deploy script (`DATABASE_URL`, `JWT_SECRET` via `.env`)
- [x] Rollback owner/channel represented in runbook (process-level readiness)
- [~] Backup snapshot restoration not executed directly in this local rehearsal

## Release Sequence Result (DB + API)
- [x] Migration deploy path executed from clean DB (`prisma migrate deploy`)
- [x] API booted successfully after migration
- [x] Health endpoint responded with expected payload (`{"ok":true,"service":"teman-tuli-backend"}`)
- [x] No schema drift dependency observed

## Smoke Test Result
- [x] **Verified by command parity:** integration tests cover auth/session create/update/delete and feedback flow.
- [x] **Verified by command parity:** user-scope authorization boundaries and resilience scenarios pass.
- [~] Manual remote-host `/docs` and route curl checks not executed (local rehearsal mode).

## Rollback Trigger Decision Notes
- No rollback triggered during rehearsal.
- Trigger criteria reviewed against runbook and remain decision-complete for operations handoff:
  - sustained 5xx,
  - auth failure spike,
  - migration query failures,
  - user-scope authorization regression,
  - transcript data integrity anomaly.

## Findings
- Outcome: **PASS (rehearsal baseline complete)**
- Blocking issues: none
- Non-blocking notes:
  - `npm audit` warnings surfaced during dependency install in verifier script; no runtime blocker observed for this rehearsal.
  - Full production backup/restore drill still recommended in staging before public rollout.

## Classification
This rehearsal is recorded as:
- `executed` for local migration + health + quality-gate proof,
- `simulated/verified by command parity` for hosted post-deploy smoke paths not run against a remote deployment target.
