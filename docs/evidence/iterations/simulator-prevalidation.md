# Simulator Pre-Validation Evidence

## Purpose
Capture useful iOS Simulator evidence while physical iPhone access is unavailable.

## Validation Position
This artifact is used as the primary validation evidence for the current MVP scope.
Real-device expansion can be scheduled as a follow-up quality pass.

## Recommended Simulator Scope
Use Simulator to validate only non-hardware-critical behavior:
- onboarding/auth UI paths,
- basic navigation and archive flow,
- empty-state and validation messages,
- error-state copy and recovery CTA visibility,
- visual accessibility checks (layout/readability/static text sizing).

## Follow-Up Quality Pass Areas
For higher confidence in future release phases, prioritize:
- microphone and speech reliability,
- AVAudio interruption behavior,
- call/background/foreground recovery,
- save reliability under real-device conditions.

## Evidence Capture Template

### Run `<YYYY-MM-DD HH:mm TZ>`
- Xcode version:
- iOS Simulator device + OS:
- Build target / commit hash:

#### Checks
- [ ] Onboarding and login flow reachable
- [ ] Register/login fail states visible and clear
- [ ] Main caption screen opens
- [ ] Archive list/detail navigation works
- [ ] Notes/feedback UI paths accessible
- [ ] Empty/validation/error UI copy reviewed

#### Findings
- Strengths:
- Issues found:
- Follow-up checks (if any):

#### Artifacts
- Screenshots path(s):
- Screen recording path (optional):

## Ready-to-Run Physical Device Handoff
When iPhone is available, execute in this order:
1. `docs/evidence/iterations/execution-runbook.md`
2. `docs/evidence/iterations/device-test-matrix.md`
3. `docs/evidence/iterations/p0.1-validation-log.md`
