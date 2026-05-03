# Iteration Log

## Iteration 1 — Problem Reframing
- Input: Project goal shifted from productivity to SDG-linked inclusion.
- Change: Pivoted product to Teman Tuli for classroom accessibility.
- Why: Stronger non-mainstream impact story and clearer SDG alignment.

## Iteration 2 — Privacy-First MVP
- Input: Classroom transcripts may contain sensitive student discussion.
- Change: No automatic upload; user explicitly saves private transcripts.
- Why: Trust is central for accessibility products.

## Iteration 3 — Technical Scope Control
- Input: Need simple and shippable v1.
- Change: Apple Speech framework on-device for captions; backend stores approved archives only.
- Why: Lower cost, faster MVP, stronger iOS relevance for the project.

## Iteration 4 — Reliability Hardening
- Input: Need robust end-to-end flow with clear recovery paths.
- Change: Added auth expired handling, network/permission fallback UX, and login mode support in onboarding.
- Why: Prevent dead-end states during real-device usage.

## Iteration 5 — Execution Evidence System
- Input: Sprint requires factual quality evidence.
- Change: Added device test matrix template and execution runbook.
- Why: Ensure test execution is operational, not only conceptual.

## Iteration 6 — Priority 0.1 Validation Controls
- Input: Priority 0.1 needs objective closure gates and batch-by-batch traceability.
- Change: Hardened matrix/runbook scoring rules and added P0.1 batch validation ledger with explicit quality gates.
- Why: Prevent subjective completion claims and keep milestone evidence auditable.

## Iteration 7 — Priority 0.2 Reproducibility Runbook
- Input: Need deterministic migration bootstrap steps and expected outputs for clean environment checks.
- Change: Added backend README section for clean DB reset, `prisma:deploy` verification signals, API health validation, and drift guard rule.
- Why: Ensure another engineer can reproduce migration bootstrap without tribal knowledge.

## Iteration 8 — Priority 0.3 Env & Secret Hygiene
- Input: Need deterministic env contracts and safer secret handling across dev/staging/prod.
- Change: Added env/secret policy document, rotation guidance, and tightened runtime env validation outside test mode.
- Why: Reduce misconfiguration risk and prevent accidental weak-secret defaults in runtime environments.

## Iteration 9 — Priority 1.4 API Resilience Safeguards
- Input: Need safer API behavior under malformed and high-volume traffic before launch.
- Change: Added route body limits, transcript payload guards, auth/write rate limiting, and standardized operational error envelope.
- Why: Keep API behavior predictable during abusive traffic, oversized payloads, and runtime failures.

## Iteration 10 — Priority 1.5 Observability Baseline
- Input: Need faster incident diagnosis with consistent request tracing and triage metadata.
- Change: Added correlation-ID propagation, structured request lifecycle logs, and documented monitoring rollout plan.
- Why: Reduce debugging guesswork and speed up operational response for backend incidents.

## Iteration 11 — Priority 2.7-2.9 Launch Readiness
- Input: Need launch-grade safeguards for privacy policy clarity, CI gate enforcement, and repeatable release operations.
- Change: Added retention policy note, expanded cross-user authorization negative tests, added PR CI workflow, and added release/rollback runbook.
- Why: Ensure launch claims are backed by runtime verification and repeatable operational procedures.

## Iteration 12 — Simulator Evidence Bridge
- Input: Physical iPhone access is unavailable, but execution evidence progress must continue.
- Change: Added simulator pre-validation evidence template and linked it from evidence index and TODO blocker notes.
- Why: Keep documentation and review readiness moving without falsely claiming real-device sign-off.
