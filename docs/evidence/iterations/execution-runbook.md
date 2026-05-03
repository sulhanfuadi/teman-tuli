# Demo Runbook (3 Minutes)

## Goal
Deliver one clean take showing problem-solution flow without blockers.

## Pre-Demo Setup (5-10 min)
- Ensure backend is running (`apps/teman-tuli-api`).
- Ensure test account is available (or register quickly in-app).
- Open app at onboarding/login screen.
- Keep one short script audio source ready for caption demonstration.
- Prepare fallback sentence if speech permission prompt appears.

## Demo Sequence
1. **Problem framing (10-15s)**
   - “Teman Tuli helps Deaf students follow fast class discussions with live caption and private transcript.”
2. **Auth flow (15-20s)**
   - Login (or quick register) and enter app.
3. **Live caption flow (45-60s)**
   - Start caption, show readable text, adjust caption size briefly.
   - Stop recording and tap `Simpan Privat`.
4. **Archive flow (40-50s)**
   - Open Transkrip list, open detail session, add notes, submit feedback.
5. **Privacy statement (15-20s)**
   - Explicitly mention: no auto-upload, save is explicit, private-by-default.
6. **Technical close (20-25s)**
   - Mention SwiftUI + Speech on iOS and Fastify + Prisma backend.

## Fallback Handling (if issue happens)
- If speech permission denied: show permission message + explain recovery action.
- If network error on save: show error card + retry after backend check.
- If auth expired: show automatic return-to-login behavior.

## Done Criteria
- One uninterrupted take with core flow complete.
- Privacy message delivered clearly.
- No dead-end state during recording.
