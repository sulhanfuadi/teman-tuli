# Case Study B — Technical Architecture Decisions

## Objective
Deliver an end-to-end accessibility product system with clear iOS relevance and privacy-safe backend behavior.

## Stack
- iOS: SwiftUI + MVVM + Speech + AVFoundation
- Backend: Fastify + Prisma + PostgreSQL
- Auth: JWT
- Contract: OpenAPI

## Key Architecture Choices
- Speech recognition runs on iOS; backend does not listen to microphone audio.
- Backend stores only saved transcript sessions selected by the user.
- Sessions are private by default and scoped to authenticated users.
- Feedback endpoint captures caption quality for iteration evidence.

## Testing Approach
- Backend unit tests for transcript-session rules.
- Backend integration tests for auth, save/list/read/update/feedback/delete, and privacy isolation.
- iOS view-model tests for archive loading and notes updates.

## Tradeoffs
- Apple Speech framework may be less accurate in noisy classrooms.
- v1 avoids sharing flows to protect privacy and reduce moderation complexity.
- Transcript corrections and exports are deferred to v2.
