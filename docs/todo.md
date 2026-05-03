# Teman Tuli — Execution TODO (Production Readiness)

This file is the execution baseline for next implementation cycles.

_Last updated: 2026-05-04 (Asia/Jakarta)_

## Current Status Snapshot
- **Completed:** P0.2, P0.3, P1.4, P1.5, P2.7, P2.8, P2.9.
- **Phase 1 launch-prep completed:** simulator evidence + release rehearsal + tracking sync.
- **Remaining production gates:** P0.1 and P1.6 real-device execution only.
- **Readiness label:** simulator-ready for internal demo/pilot (not final public-production sign-off).

## How to Use
- Execute from top to bottom by priority.
- Do not start a lower-priority item before blocker items are resolved.
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
- `2026-05-03`: Milestone 2 started — batch validation ledger added for quality evidence capture.
- `2026-05-03`: Milestone 3 prep complete — closure protocol documented for current simulator-first MVP validation.
- `2026-05-04`: Handoff pack finalized (execution order, matrix fill rules, copy-paste batch template, objective closure gates).
- `2026-05-04`: Physical execution still pending first Quiet batch.

### 2) Backend Migration Reproducibility Check
- [x] Verify baseline migration applies from clean DB using committed migration files. (`2026-05-03`)
- [x] Confirm app can run after `prisma:deploy` only (without ad-hoc local schema drift). (`2026-05-03`)
- [x] Document exact command sequence and expected outputs in backend README. (`2026-05-03`)
- **Done when:** a clean environment can reliably bootstrap DB and run API.

#### P0.2 Progress (Date-Stamped)
- `2026-05-03`: Added deterministic clean-bootstrap + health-check runbook in `apps/teman-tuli-api/README.md`.
- `2026-05-03`: Added runnable verifier script `apps/teman-tuli-api/scripts/verify-p0.2-migration-repro.sh` for Docker-enabled execution.
- `2026-05-03`: Verification succeeded end-to-end on Docker-enabled environment: clean DB reset, `prisma:deploy`, and API `/health` boot check passed.

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

### 5) Observability Baseline
- [x] Add structured server logs with request correlation IDs. (`2026-05-03`)
- [x] Define minimal incident triage fields (route, status, user scope, timestamp). (`2026-05-03`)
- [x] Add error monitoring plan (tool choice + integration steps documented). (`2026-05-03`)
- **Done when:** failures can be diagnosed quickly without guessing.

### 6) iOS Runtime Reliability Sweep
- [ ] Validate interruption handling for call/background/foreground on physical device.
- [ ] Verify no stale recording state after interruption recovery.
- [ ] Confirm user-facing guidance is clear in all fallback states.
- **Done when:** caption flow recovers safely and consistently in real usage.

#### P1.6 Validation Notes
- `2026-05-03`: Simulator-first evidence path added as current MVP baseline (`docs/evidence/iterations/simulator-prevalidation.md`).
- `2026-05-04`: Local Xcode + iOS Simulator runtime prepared; simulator build currently passes (`BUILD SUCCEEDED`) for `TemanTuli`.
- `2026-05-04`: Real-device interruption closure gates documented in `docs/evidence/iterations/execution-runbook.md` and `docs/evidence/iterations/p0.1-validation-log.md`.

---

## Priority 2 — Launch Readiness

### 7) Security & Privacy Readiness Check
- [x] Confirm private-by-default behavior remains intact across all flows. (`2026-05-03`)
- [x] Add explicit retention/deletion policy note for transcript data. (`2026-05-03`)
- [x] Validate user-scoped authorization boundaries with negative tests. (`2026-05-03`)
- **Done when:** privacy claims in docs match runtime behavior.

### 8) CI Baseline (Quality Gate)
- [x] Add CI workflow to run backend `npm test` + `npm run build` on pull requests. (`2026-05-03`)
- [x] Add status badge and failure troubleshooting notes. (`2026-05-03`)
- **Done when:** regressions are automatically blocked before merge.

### 9) Release Runbook
- [x] Create release checklist (pre-flight, migration, smoke test, rollback triggers). (`2026-05-03`)
- [x] Define rollback steps for DB migration and API release. (`2026-05-03`)
- [x] Add post-release verification checklist. (`2026-05-03`)
- [x] Record rehearsal evidence with pass/fail outcomes. (`2026-05-04`)
- **Done when:** release can be repeated by another engineer without tribal knowledge.

#### P2.9 Completion Notes (Date-Stamped)
- `2026-05-03`: Added operational release runbook in `docs/release-runbook.md`.
- `2026-05-04`: Rehearsal evidence captured in `docs/evidence/iterations/release-rehearsal-2026-05-04.md` with command parity notes.

---

## Next Action When iPhone Is Available (Time-Boxed)
1. **0-10 min:** run pre-setup checklist in `docs/evidence/iterations/execution-runbook.md`.
2. **10-35 min:** execute Quiet batch (3 sessions), update matrix + batch log.
3. **35-60 min:** execute Moderate batch (3 sessions), update matrix + batch log.
4. **60-85 min:** execute Noisy batch (3 sessions), update matrix + batch log.
5. **85-100 min:** run closure checks for P0.1 and P1.6 and update this TODO status.

---

## Notes
- Keep API contract under `/api/v1` unless change is strictly necessary.
- Prioritize reliability over new features.
- Keep transcript privacy defaults unchanged.
- Simulator validation is baseline evidence; real-device evidence is the final production gate.
