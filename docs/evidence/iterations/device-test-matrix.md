# Device Test Matrix — Priority 0.1 Validation

## Objective
Validate core flow on physical iPhone and capture actionable quality evidence for production-readiness decision.

## Completion Gate (Must Pass)
- All 9 sessions are filled with non-placeholder values.
- Mandatory E2E checklist is evidenced with pass/fail and notes.
- Critical failures are either resolved or have mitigation + reproducible steps.
- Unknown critical behavior count is `0`.

## Scoring Guide (Use Consistently)
- **Readability (1-5):** 1 = mostly unreadable, 3 = readable with frequent strain, 5 = easy to read continuously.
- **Continuity (1-5):** 1 = frequent drops/stalls, 3 = occasional gaps, 5 = stable continuous updates.
- **Confidence (1-5):** 1 = untrusted output, 3 = mixed reliability, 5 = reliable enough for classroom following.

## Matrix Fill Rules
- Replace every `-` placeholder with real values.
- `Save Success` must be explicit (`Yes` / `No` + short note in Evidence Notes).
- `Permission Edge Case`, `Interruption Behavior`, and `Save Retry Outcome` must never be left generic once tested.

## Environment Matrix (9 Sessions)
| Batch | Environment | Session | Duration | Readability (1-5) | Continuity (1-5) | Save Success | Confidence (1-5) | Permission Edge Case | Interruption Behavior | Save Retry Outcome | Evidence Notes |
|---|---|---:|---:|---:|---:|---|---:|---|---|---|---|
| Quiet | Quiet room | 1 | 1-3 min | - | - | - | - | Not tested | Not triggered | Not needed | Pending device test |
| Quiet | Quiet room | 2 | 1-3 min | - | - | - | - | Not tested | Not triggered | Not needed | Pending device test |
| Quiet | Quiet room | 3 | 1-3 min | - | - | - | - | Not tested | Not triggered | Not needed | Pending device test |
| Moderate | Moderate classroom noise | 1 | 1-3 min | - | - | - | - | Not tested | Not triggered | Not needed | Pending device test |
| Moderate | Moderate classroom noise | 2 | 1-3 min | - | - | - | - | Not tested | Not triggered | Not needed | Pending device test |
| Moderate | Moderate classroom noise | 3 | 1-3 min | - | - | - | - | Not tested | Not triggered | Not needed | Pending device test |
| Noisy | Noisy room | 1 | 1-3 min | - | - | - | - | Not tested | Not triggered | Not needed | Pending device test |
| Noisy | Noisy room | 2 | 1-3 min | - | - | - | - | Not tested | Not triggered | Not needed | Pending device test |
| Noisy | Noisy room | 3 | 1-3 min | - | - | - | - | Not tested | Not triggered | Not needed | Pending device test |

## Example Row (Reference Only, Not Counted)
| Batch | Environment | Session | Duration | Readability (1-5) | Continuity (1-5) | Save Success | Confidence (1-5) | Permission Edge Case | Interruption Behavior | Save Retry Outcome | Evidence Notes |
|---|---|---:|---:|---:|---:|---|---:|---|---|---|---|
| Example | Quiet room | E1 | 2 min | 4 | 4 | Yes | 4 | Mic denied once, guidance shown, retried after allow | Background once; resumed with manual start | Retry 1x, final save success | Use this style for concise factual notes |

## Batch Evidence Submission Format
Use this exact format when reporting each 3-session batch:

### Batch `<Quiet|Moderate|Noisy>` — `<YYYY-MM-DD>`
- Session 1 summary:
- Session 2 summary:
- Session 3 summary:
- E2E checklist delta (newly verified items only):
- P1.6 interruption coverage delta:
- Failure modes found (if any):
- Open unknowns after batch:

## Mandatory E2E Checklist (Pass/Fail + Notes)
| Checkpoint | Status | Notes |
|---|---|---|
| Register success | Pending | - |
| Login success | Pending | - |
| Login fail state shown clearly | Pending | - |
| Start caption works normally | Pending | - |
| Stop caption works normally | Pending | - |
| Empty transcript save blocked with clear message | Pending | - |
| Private save success and item appears in archive | Pending | - |
| Session detail loads correctly | Pending | - |
| Notes update works | Pending | - |
| Feedback submit works | Pending | - |
| Unauthorized state forces re-login path (auth expired) | Pending | - |
| Network error shows recovery action | Pending | - |

## Critical Failure Mode Taxonomy
| Category | Severity | Definition | Required Capture |
|---|---|---|---|
| Auth Flow Failure | Critical | User cannot enter or recover session | exact step, screen state, error text, workaround |
| Caption Session Dead-End | Critical | Start/stop path cannot continue safely | trigger condition, visible UI state, recovery success |
| Save/Data Integrity Issue | Critical | transcript cannot be saved/retrieved correctly | payload/action, retry count, final persisted state |
| Permission Handling Regression | High | denied/restricted permission creates broken UX | permission state, prompt behavior, guidance quality |
| Interruption Recovery Failure | High | call/background interruption leaves stale state | interruption type, app state transition, recovery result |

## Unknowns Tracker (Must Be Empty at Done)
| ID | Description | Severity | Discovered In | Owner | Mitigation Plan | Status |
|---|---|---|---|---|---|---|
| _No open unknowns yet_ | - | - | - | - | - | - |

## Current Status
- `2026-05-03`: Matrix upgraded for Priority 0.1 execution.
- `2026-05-03`: Unknowns tracker reset to neutral baseline (no pre-filled open items).
- `2026-05-04`: Matrix handoff finalized with fill rules + reference example for consistent scoring and logging.
- Physical device execution is pending first Quiet batch.
