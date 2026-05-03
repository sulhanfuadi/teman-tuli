# Teman Tuli — Execution TODO (Production Readiness)

This file is the execution baseline for next implementation cycles.

## How to Use
- Execute from top to bottom by priority.
- Do not start a lower-priority item before the blocker in higher priority is done.
- Mark status with `[ ]` / `[x]` and append date notes when completed.

---

## Priority 0 — Must Finish Before Public Production

### 1) Real Device Validation Matrix (iPhone)
- [ ] Run 9 caption sessions (quiet / moderate / noisy, 3 each) using `docs/evidence/iterations/device-test-matrix.md`.
- [ ] Fill all quality fields: readability, continuity, save success, confidence.
- [ ] Log concrete failure modes (permission edge cases, interruption behavior, save retries).
- [ ] Record each 3-session batch in `docs/evidence/iterations/p0.1-validation-log.md`.
- [ ] Pass all P0.1 quality gates before marking done.
- **Done when:** matrix is fully filled with evidence-based notes and no unknown critical behavior remains.

#### P0.1 Milestone Progress (Date-Stamped)
- `2026-05-03`: Milestone 1 complete — matrix and runbook hardened with explicit scoring, failure taxonomy, and unknown tracker.
- `2026-05-03`: Milestone 2 started — batch validation ledger added; waiting physical iPhone evidence for Quiet/Moderate/Noisy.
- `2026-05-03`: Milestone 3 prep complete — closure protocol documented; final completion still blocked on real-device execution evidence.
- `2026-05-03`: Added simulator pre-validation template (`docs/evidence/iterations/simulator-prevalidation.md`) to keep progress moving while iPhone access is unavailable.

### 2) Backend Migration Reproducibility Check
- [ ] Verify baseline migration applies from clean DB using committed migration files.
- [ ] Confirm app can run after `prisma:deploy` only (without ad-hoc local schema drift).
- [x] Document exact command sequence and expected outputs in backend README. (`2026-05-03`)
- **Done when:** a clean environment can reliably bootstrap DB and run API.

#### P0.2 Progress (Date-Stamped)
- `2026-05-03`: Added deterministic clean-bootstrap + health-check runbook in `apps/teman-tuli-api/README.md`.
- `2026-05-03`: Local runtime blocker detected (`docker` unavailable), so clean DB reset verification remains pending until Docker-enabled environment is used.

### 3) Production Environment & Secret Hygiene
- [x] Define required env vars for dev/staging/prod (`DATABASE_URL`, `JWT_SECRET`, etc.). (`2026-05-03`)
- [x] Ensure no sensitive values are hardcoded or committed. (`2026-05-03`)
- [x] Add deployment-safe env documentation and rotation guidance. (`2026-05-03`)
- **Done when:** environment setup is deterministic and secret handling is explicit.

#### P0.3 Completion Notes (Date-Stamped)
- `2026-05-03`: Added `apps/teman-tuli-api/docs/environment-secrets.md` with env matrix and rotation runbook.
- `2026-05-03`: Hardened `src/config/env.ts` to require `DATABASE_URL` and `JWT_SECRET` outside test runtime.
- `2026-05-03`: Verified backend quality gates after env hardening: `npm test` and `npm run build` passed.

---

## Priority 1 — Reliability & Safety Hardening

### 4) API Resilience Safeguards
- [x] Add request size limits and payload guards for transcript-heavy endpoints. (`2026-05-03`)
- [x] Add rate limiting strategy for auth and write endpoints. (`2026-05-03`)
- [x] Standardize error responses for operational debugging. (`2026-05-03`)
- **Done when:** API behavior under malformed/high-volume requests is controlled and predictable.

#### P1.4 Completion Notes (Date-Stamped)
- `2026-05-03`: Added route-level body limits and transcript payload guards (`fullText`, `segments`, `segment.text`).
- `2026-05-03`: Added `@fastify/rate-limit` with route policies for auth and write endpoints.
- `2026-05-03`: Added standardized error envelope `{ message, code, requestId, details? }` and normalization for framework-level validation/body-size errors.
- `2026-05-03`: Added integration resilience tests and verified `npm test` + `npm run build` pass.

### 5) Observability Baseline
- [x] Add structured server logs with request correlation IDs. (`2026-05-03`)
- [x] Define minimal incident triage fields (route, status, user scope, timestamp). (`2026-05-03`)
- [x] Add error monitoring plan (tool choice + integration steps documented). (`2026-05-03`)
- **Done when:** failures can be diagnosed quickly without guessing.

#### P1.5 Completion Notes (Date-Stamped)
- `2026-05-03`: Added observability plugin with `x-correlation-id` propagation and structured `api_request_completed`/`api_request_failed` logs.
- `2026-05-03`: Added minimum incident triage fields in logs (`route`, `statusCode`, `userScope`, `timestamp`, `requestId`, `correlationId`).
- `2026-05-03`: Added monitoring plan with tool choice and rollout steps in `apps/teman-tuli-api/docs/observability-baseline.md`.
- `2026-05-03`: Added integration coverage for correlation-id behavior and re-ran backend quality checks.

### 6) iOS Runtime Reliability Sweep
- [ ] Validate interruption handling for call/background/foreground on physical device.
- [ ] Verify no stale recording state after interruption recovery.
- [ ] Confirm user-facing guidance is clear in all fallback states.
- **Done when:** caption flow recovers safely and consistently in real usage.

#### P1.6 Blocker Note
- Physical iPhone is currently unavailable; simulator evidence can be collected, but it cannot replace physical-device runtime validation.

---

## Priority 2 — Launch Readiness

### 7) Security & Privacy Readiness Check
- [x] Confirm private-by-default behavior remains intact across all flows. (`2026-05-03`)
- [x] Add explicit retention/deletion policy note for transcript data. (`2026-05-03`)
- [x] Validate user-scoped authorization boundaries with negative tests. (`2026-05-03`)
- **Done when:** privacy claims in docs match runtime behavior.

#### P2.7 Completion Notes (Date-Stamped)
- `2026-05-03`: Added explicit v1 retention policy (manual delete only) in backend README.
- `2026-05-03`: Extended negative authorization tests for cross-user `PATCH`, `DELETE`, and `POST /feedback` access attempts.
- `2026-05-03`: Re-validated backend quality gates (`npm test`, `npm run build`).

### 8) CI Baseline (Quality Gate)
- [x] Add CI workflow to run backend `npm test` + `npm run build` on pull requests. (`2026-05-03`)
- [x] Add status badge and failure troubleshooting notes. (`2026-05-03`)
- **Done when:** regressions are automatically blocked before merge.

#### P2.8 Completion Notes (Date-Stamped)
- `2026-05-03`: Added GitHub Actions workflow `.github/workflows/backend-ci.yml` for PR quality gate.
- `2026-05-03`: Added backend CI badge and troubleshooting section in `apps/teman-tuli-api/README.md`.

### 9) Release Runbook
- [x] Create release checklist (pre-flight, migration, smoke test, rollback triggers). (`2026-05-03`)
- [x] Define rollback steps for DB migration and API release. (`2026-05-03`)
- [x] Add post-release verification checklist. (`2026-05-03`)
- **Done when:** release can be repeated by another engineer without tribal knowledge.

#### P2.9 Completion Notes (Date-Stamped)
- `2026-05-03`: Added operational release runbook in `docs/release-runbook.md`.
- `2026-05-03`: Included pre-flight, migration sequence, smoke checks, rollback triggers, DB+API rollback, and post-release verification.

---

## Immediate Next Sprint (Recommended Execution Order)
1. Complete Priority 0.1 (real device matrix on physical iPhone).
2. Complete Priority 0.2 verification in Docker-enabled environment (`prisma:deploy` + API boot check).
3. Complete Priority 1.6 (iOS runtime reliability sweep on physical device).
4. Run one release rehearsal using `docs/release-runbook.md` before public production.

---

## Notes
- Keep API contract under `/api/v1` unless change is strictly necessary.
- Prioritize reliability over new features.
- Keep transcript privacy defaults unchanged.
- Priority 0.1 cannot be checked complete until all 9 sessions are executed on physical iPhone.
