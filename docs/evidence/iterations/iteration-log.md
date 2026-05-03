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
