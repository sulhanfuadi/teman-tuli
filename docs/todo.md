# Teman Tuli — Execution TODO (Simulator-First Readiness)

This file is the execution baseline for next implementation cycles.

_Last updated: 2026-05-04 (Asia/Jakarta)_

## Current Status Snapshot

- **Completed:** P0.1, P0.2, P0.3, P1.4, P1.5, P1.6, P1.7, P2.7, P2.8, P2.9.
- **Testing policy (fixed):** full validation uses iOS Simulator only.
- **Coding simulator scope:** complete (harness + XCUITest + guards + error UX).
- **Primary remaining work:** none for simulator-first scope (execution phase closed).
- **English app migration:** completed (UI copy, speech locale en-US, error UX, tests green).
- **Readiness label target:** simulator-ready for internal demo/pilot.

## Important Scope Decision

- Physical iPhone testing is **not part of current execution scope**.
- All remaining validation must be completed with simulator-based evidence.
- Any hardware-specific confidence gap must be documented as known limitation, not hidden.

## How to Use

- Execute from top to bottom by priority.
- Mark status with `[ ]` / `[x]` and append date notes when completed.
- Keep evidence links updated in each completion note.

---

## Priority 0 — Must Finish Before Simulator-Only Pilot

### 1) Validation Matrix Closure (Simulator)

- [x] Run 9 caption sessions (quiet / moderate / noisy, 3 each) using `docs/evidence/iterations/device-test-matrix.md`. (`2026-05-04`)
- [x] Fill quality fields for each session: readability, continuity, save success, confidence. (`2026-05-04`)
- [x] Log failure modes (permission edge cases, interruption behavior, save retries) from simulator runs. (`2026-05-04`)
- [x] Record each 3-session batch in `docs/evidence/iterations/p0.1-validation-log.md`. (`2026-05-04`)
- [x] Pass quality gates and close unknown tracker for simulator scope. (`2026-05-04`)
- **Done when:** all 9 rows are filled, E2E checklist is evidenced, and unknown critical behavior count is `0` for simulator scope.

#### P0.1 Progress (Date-Stamped)

- `2026-05-03`: Matrix/runbook hardened with scoring, taxonomy, and unknown tracker.
- `2026-05-04`: Simulator workflow and handoff pack finalized for direct execution.
- `2026-05-04`: Status updated to simulator-only closure path.
- `2026-05-04`: Matrix execution + logs completed; simulator validation closure accepted.

### 2) Backend Migration Reproducibility Check

- [x] Verify baseline migration applies from clean DB using committed migration files. (`2026-05-03`)
- [x] Confirm app can run after `prisma:deploy` only (without local schema drift). (`2026-05-03`)
- [x] Document exact command sequence and expected outputs in backend README. (`2026-05-03`)
- **Done when:** clean environment reliably bootstraps DB and runs API.

### 3) Production Environment & Secret Hygiene

- [x] Define required env vars for dev/staging/prod (`DATABASE_URL`, `JWT_SECRET`, etc.). (`2026-05-03`)
- [x] Ensure no sensitive values are hardcoded or committed. (`2026-05-03`)
- [x] Add deployment-safe env documentation and rotation guidance. (`2026-05-03`)
- **Done when:** environment setup is deterministic and secret handling is explicit.

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

### 6) iOS Code Hardening (Completed)

- [x] Add runtime API endpoint settings with local persistence and URL guard. (`2026-05-04`)
- [x] Add archive delete flow with swipe + confirmation dialog. (`2026-05-04`)
- [x] Add friendly backend error-code mapping with compact request reference. (`2026-05-04`)
- [x] Add unit coverage and re-verify simulator build/test. (`2026-05-04`)
- **Done when:** iOS app has stable API integration UX for simulator-first validation.

#### P1.6 Completion Notes (Date-Stamped)

- `2026-05-04`: Apple-style UIX refresh completed with adaptive design system, premium app icon, and in-app brand wordmark.
- `2026-05-04`: Full English iOS migration completed (Localizable.strings, English UI/error copy, speech locale en-US, transcript languageCode=en-US).
- `2026-05-04`: Added runtime endpoint config in Settings (`APIEndpointConfig` + `LiveAPIClient` base URL provider).
- `2026-05-04`: Added transcript delete flow in archive list with confirmation and feedback messaging.
- `2026-05-04`: Added shared `APIErrorMessageFormatter` for `code/requestId` mapping across onboarding, sessions, detail, and live save flow.
- `2026-05-04`: Passed `xcodebuild ... build` and `xcodebuild ... test` after target test plist generation update.

### 7) Runtime Reliability Sweep (Simulator)

- [x] Validate interruption handling equivalent paths (background/foreground, audio interruption simulation) on simulator. (`2026-05-04`)
- [x] Verify no stale recording state after interruption recovery on simulator. (`2026-05-04`)
- [x] Confirm user-facing fallback guidance is clear in all simulated error states. (`2026-05-04`)
- [x] Document simulator-only limitation note for hardware-dependent microphone behavior. (`2026-05-04`)
- **Done when:** simulator reliability checks pass and known limitation notes are recorded explicitly.

#### P1.7 Progress (Date-Stamped)

- `2026-05-04`: Launch-argument harness, deterministic interruption simulation, and UI automation target completed.
- `2026-05-04`: Action guards + request-reference copy UX completed across onboarding, live caption, sessions, and detail flows.
- `2026-05-04`: Happy-path core + delete XCUITest scenarios completed and passing.
- `2026-05-04`: Remaining task is evidence capture, not backend/API implementation.
- `2026-05-04`: Simulator speech-start abort mitigated with simulator fallback message; crash no longer blocks simulator execution flow.

---

## Priority 2 — Launch Readiness

### 8) Security & Privacy Readiness Check

- [x] Confirm private-by-default behavior remains intact across all flows. (`2026-05-03`)
- [x] Add explicit retention/deletion policy note for transcript data. (`2026-05-03`)
- [x] Validate user-scoped authorization boundaries with negative tests. (`2026-05-03`)
- **Done when:** privacy claims in docs match runtime behavior.

### 9) CI Baseline (Quality Gate)

- [x] Add CI workflow to run backend `npm test` + `npm run build` on pull requests. (`2026-05-03`)
- [x] Add status badge and troubleshooting notes. (`2026-05-03`)
- **Done when:** regressions are blocked before merge.

### 10) Release Runbook

- [x] Create release checklist (pre-flight, migration, smoke test, rollback triggers). (`2026-05-03`)
- [x] Define rollback steps for DB migration and API release. (`2026-05-03`)
- [x] Add post-release verification checklist. (`2026-05-03`)
- [x] Record rehearsal evidence with pass/fail outcomes. (`2026-05-04`)
- **Done when:** release can be repeated by another engineer without tribal knowledge.

---

## Next Execution Queue (Simulator-Only)

1. Archive current evidence set and keep traceability links stable.
2. Proceed to optional real-device validation as a separate phase (out of current scope).
3. Continue product polish/documentation without reopening closed simulator gates.

## Operator Checklist (Now)

- [x] `docs/evidence/iterations/execution-runbook.md` opened.
- [x] `docs/evidence/iterations/device-test-matrix.md` opened.
- [x] `docs/evidence/iterations/p0.1-validation-log.md` opened.
- [x] Backend running and reachable.
- [x] Simulator-first execution batches completed.

---

## Notes

- Keep API contract under `/api/v1` unless change is strictly necessary.
- Prioritize reliability over new features.
- Keep transcript privacy defaults unchanged.
- Final readiness in this phase is **simulator-ready**, not hardware-certified.
