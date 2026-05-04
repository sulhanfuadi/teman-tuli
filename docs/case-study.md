# Teman Tuli — Case Study

## Problem
Deaf and hard-of-hearing students can lose critical context in fast-paced classroom discussions due to pace, overlap, and delayed notes.

## Why This Matters
When context is missed repeatedly, students face higher cognitive load, reduced confidence, and unequal participation opportunities.

## What I Built
- iOS app focused on live caption readability and private-first transcript flow.
- Backend API (`/api/v1`) for authenticated, user-scoped transcript sessions and feedback.
- Transcript archive with detail view, private notes, and quality feedback capture.
- Simulator-first execution evidence flow with clear reliability and limitation tracking.

## Key Tradeoffs
- **Privacy vs convenience:** Chose explicit user-triggered save instead of automatic upload.
- **Speed vs hardware realism:** Used simulator-first validation to keep iteration fast, while documenting microphone/speech constraints requiring real-device verification.
- **Polish vs scope:** Prioritized clarity, resilience, and accessibility over feature breadth.

## What I Learned
- Accessibility UX quality depends heavily on typography, contrast, and stable interaction states.
- Reliability and fallback messaging are core product value, not “extra” work.
- Good iteration requires evidence logs, testable checkpoints, and honest limitation notes.

## Outcome
Teman Tuli reached simulator-ready internal demo quality with:
- complete core flows,
- structured evidence artifacts,
- improved visual consistency,
- and stronger portfolio narrative around inclusive product thinking.
