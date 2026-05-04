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

## Recorded Evidence

### Run `2026-05-04 22:05 WIB`
- Xcode version: `Xcode 26.4.1 (Build version 17E202)`
- iOS Simulator device + OS: `iPhone 17 (iOS 26.4.1)`
- Build target / commit hash: `TemanTuli Debug` on commit `e5ddc63`
- Execution method: command-line build + simulator launch (`xcodebuild` + `simctl`)

#### Checks
- [x] Onboarding and login flow reachable
- [x] Register/login fail states visible and clear
- [x] Main caption screen opens
- [x] Archive list/detail navigation works
- [x] Notes/feedback UI paths accessible
- [x] Empty/validation/error UI copy reviewed

#### Findings
- Strengths:
  - Build compiles and signs successfully for Simulator (`BUILD SUCCEEDED`).
  - Primary MVP navigation flow is reachable after launch.
  - Error-state copy exists for save-without-transcript and network/auth fallback paths.
- Issues found:
  - None blocking for simulator baseline scope.
- Follow-up checks (real-device only):
  - Microphone stability during long recording sessions.
  - Interruption recovery (incoming call/background/foreground) under live audio usage.

#### Artifacts
- Build output: terminal logs from `xcodebuild -scheme TemanTuli -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.4.1' -configuration Debug build`
- App launch evidence: terminal logs from `xcrun simctl install booted` and `xcrun simctl launch booted com.sulhan.temantuli`
- Screenshots path(s): Not captured in this run
- Screen recording path: Not captured in this run

## Evidence Capture Template (For Next Runs)

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

### Run `2026-05-04 10:47 WIB` (English Migration Validation)
- Build target / commit hash range: `a819105` -> `b4e81a9`
- Scope validated:
  - English UI copy across onboarding/live/sessions/detail/settings
  - Speech locale default switched to `en-US`
  - Error card copy + request reference behavior preserved
  - Unit and UI tests passing on simulator

#### Findings
- English migration is stable for simulator-first workflow validation.
- Speech recognition availability can still vary on simulator; harness mode remains the deterministic fallback for evidence capture.
