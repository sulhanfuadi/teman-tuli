# Priority 0.1 Execution Runbook (Real Device)

## Goal
Run 9 physical iPhone caption sessions in 3 validated batches and produce objective evidence for Priority 0.1 closure.

## Batch Workflow (Required Order)
1. Run **Quiet batch** (3 sessions, 1-3 minutes each), then submit evidence.
2. Run **Moderate batch** (3 sessions), then submit evidence.
3. Run **Noisy batch** (3 sessions), then submit evidence.
4. After each batch, update matrix rows, checklist deltas, failure taxonomy, and unknown tracker.

Do not continue to next batch if the current batch has unresolved critical blockers without mitigation notes.

## Pre-Run Setup (5-10 min)
- Ensure backend is running (`apps/teman-tuli-api`).
- Ensure test account is available (or register quickly in-app).
- Open app at onboarding/login screen.
- Prepare short voice script (or live classroom-like source) with stable speaking pace.
- Confirm microphone/speech permission state before Session 1.
- Prepare one intentional fallback trigger for each batch:
  - permission edge-case check,
  - interruption behavior check,
  - save retry behavior check.

## Session Execution Protocol (Per Session)
1. Start at known state (logged-in, caption screen ready).
2. Run caption for 1-3 minutes.
3. Stop caption and attempt `Simpan Privat`.
4. Confirm archive visibility and open detail screen.
5. Record scores and edge-case outcomes immediately in matrix row.

## Standardized Scoring Instructions
- **Readability (1-5)**
  - `1`: text mostly unusable.
  - `2`: hard to follow with frequent strain.
  - `3`: usable with occasional strain.
  - `4`: clear with minor strain only.
  - `5`: clear and comfortable continuously.
- **Continuity (1-5)**
  - `1`: frequent stalls/dropouts.
  - `2`: unstable updates.
  - `3`: mostly stable with noticeable gaps.
  - `4`: stable with rare minor gaps.
  - `5`: smooth and continuous.
- **Confidence (1-5)**
  - `1`: cannot trust output.
  - `2`: often inaccurate for classroom following.
  - `3`: mixed reliability.
  - `4`: reliable for most parts.
  - `5`: highly reliable for intended use.

## Mandatory E2E Verification Coverage
Across the 9 sessions, evidence must cover all items:
- auth success/fail behavior,
- start/stop caption,
- empty save guard,
- private save + archive visibility,
- session detail load,
- notes update,
- feedback submit,
- auth-expired re-login path,
- network recovery path.

## Batch Evidence Submission Template
Use this format when reporting each completed batch:

```md
### Batch <Quiet|Moderate|Noisy> — <YYYY-MM-DD>
- Session 1 summary:
- Session 2 summary:
- Session 3 summary:
- E2E checklist delta (newly verified only):
- Failure modes found:
- Unknowns still open:
```

## Escalation & Logging Rules
- Log every critical/high failure into failure taxonomy with reproducible steps.
- If retry is required, record retry count and final outcome.
- If behavior is uncertain, add to unknown tracker with owner and mitigation.
- Unknown critical behavior must be `0` before closing Priority 0.1.

## Exit Criteria (Priority 0.1)
- 9 sessions completed with fully populated matrix rows.
- Mandatory E2E checklist fully evidenced (no pending rows).
- Critical failures resolved or mitigated with reproducible notes.
- Unknown tracker contains no critical open items.
