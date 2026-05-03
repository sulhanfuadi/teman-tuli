# Priority 0.1 + P1.6 Execution Runbook (Real Device)

## Goal
Execute physical iPhone validation with decision-complete evidence for:
- **P0.1:** 9-session validation matrix closure.
- **P1.6:** interruption/recovery runtime reliability closure.

## Required Execution Order (No Skips)
1. Follow this runbook (`execution-runbook.md`).
2. Fill matrix rows live (`device-test-matrix.md`).
3. Submit batch report (`p0.1-validation-log.md`).

Do not move to the next batch when unresolved **Critical** failures exist without mitigation notes.

## Time-Boxed Plan (When iPhone Is Available)
- **T+0 to T+10 min:** pre-run setup.
- **T+10 to T+35 min:** Quiet batch (3 sessions) + evidence write-up.
- **T+35 to T+60 min:** Moderate batch (3 sessions) + evidence write-up.
- **T+60 to T+85 min:** Noisy batch (3 sessions) + evidence write-up.
- **T+85 to T+100 min:** closure gate check for P0.1 + P1.6.

## Pre-Run Setup (5-10 min)
- Backend API running and reachable.
- Test account available (or register during setup).
- iPhone battery >20%, stable network (Wi-Fi or cellular).
- App starts from onboarding/login screen.
- Prepare one speaking script for consistency (~60-90 sec).
- Prepare one intentional trigger per batch:
  - permission edge case,
  - interruption scenario,
  - save retry scenario.

## Per-Session Protocol (Use Every Session)
1. Start from known state (logged in, caption screen ready).
2. Run captioning for 1-3 minutes.
3. Stop captioning and attempt `Simpan Privat`.
4. Verify archive list + detail load.
5. Record matrix values immediately (no deferred scoring).

## P1.6 Required Interruption Cases (Must Be Covered)
Across the 9 sessions, ensure all three are executed at least once:
- Background app transition and return.
- Audio interruption equivalent (call/audio takeover) and recovery.
- Resume behavior check: no stale recording state after interruption.

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

## Mandatory E2E Coverage
Evidence across all sessions must include:
- auth success/fail behavior,
- start/stop caption,
- empty save guard,
- private save + archive visibility,
- session detail load,
- notes update,
- feedback submit,
- auth-expired re-login path,
- network recovery path.

## Batch Submission Format (Copy-Paste)
```md
### Batch <Quiet|Moderate|Noisy> — <YYYY-MM-DD>
- Session 1 summary:
- Session 2 summary:
- Session 3 summary:
- E2E checklist delta (newly verified only):
- P1.6 interruption coverage delta:
- Failure modes found:
- Unknowns still open:
```

## Escalation & Logging Rules
- Log all High/Critical failures in taxonomy with reproducible steps.
- Always record retry count for save failures.
- Unknown behavior must be logged with owner + next action.
- Unknown **critical** behavior must be `0` before closure.

## Exit Criteria
### P0.1 Closure Gate
- 9 sessions completed with fully populated matrix rows.
- Mandatory E2E checklist fully evidenced.
- Critical failures resolved or mitigated with reproducible notes.
- Unknown tracker has zero critical open items.

### P1.6 Closure Gate
- Interruption handling validated for call/background/foreground equivalents.
- No stale recording state observed after interruption recovery.
- User-facing fallback guidance confirmed clear in interruption/error states.
