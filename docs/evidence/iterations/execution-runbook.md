# Priority 0.1 + P1.7 Execution Runbook (Simulator-Only)

## Goal
Execute simulator validation with decision-complete evidence for:
- **P0.1:** 9-session validation matrix closure.
- **P1.7:** interruption/recovery runtime reliability closure.

## Required Execution Order (No Skips)
1. Follow this runbook (`execution-runbook.md`).
2. Fill matrix rows live (`device-test-matrix.md`).
3. Submit batch report (`p0.1-validation-log.md`).

Do not move to the next batch when unresolved **Critical** failures exist without mitigation notes.

## Time-Boxed Plan (Simulator)
- **T+0 to T+10 min:** pre-run setup.
- **T+10 to T+35 min:** Quiet batch (3 sessions) + evidence write-up.
- **T+35 to T+60 min:** Moderate batch (3 sessions) + evidence write-up.
- **T+60 to T+85 min:** Noisy batch (3 sessions) + evidence write-up.
- **T+85 to T+100 min:** closure gate check for P0.1 + P1.7.

## Pre-Run Setup (5-10 min)
- Backend API running and reachable.
- Test account available (or register during setup).
- iOS Simulator booted and app installed.
- App starts from onboarding/login screen.
- Prepare one speaking script for consistency (~60-90 sec).
- Prepare one intentional trigger per batch:
  - permission edge case,
  - interruption simulation,
  - save retry scenario.

## Per-Session Protocol (Use Every Session)
1. Start from known state (logged in, caption screen ready).
2. Run captioning for 1-3 minutes.
3. Stop captioning and attempt `Save Privately`.
4. Verify archive list + detail load.
5. Record matrix values immediately (no deferred scoring).

## P1.7 Required Interruption Cases (Must Be Covered)
Across the 9 sessions, ensure all three are executed at least once:
- Background app transition and return.
- Audio interruption simulation and recovery.
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
- P1.7 interruption coverage delta:
- Failure modes found:
- Unknowns still open:
```

## Quiet Batch Quick Start (Today)
Use this exact order for the first 3 sessions:
1. Session Q1: normal flow + private save verification.
2. Session Q2: permission edge case (deny once, recover, retry save).
3. Session Q3: interruption simulation (background/audio), confirm recovery and no stale state.

After each session:
- Update one matrix row immediately.
- Add one concise summary line in `p0.1-validation-log.md`.

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

### P1.7 Closure Gate
- Interruption handling validated for audio/background/foreground equivalents.
- No stale recording state observed after interruption recovery.
- User-facing fallback guidance confirmed clear in interruption/error states.

## Known Simulator Limitation (Must Be Documented)
Simulator evidence is valid for workflow and UX reliability, but it does not fully represent physical microphone and hardware interruption behavior. Any residual uncertainty must be stated explicitly in closure notes.
