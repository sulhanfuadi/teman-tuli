# Observability Baseline (Priority 1.5)

This document defines the minimum observability standard for Teman Tuli backend incidents.

## Structured Log Events
The API emits two structured event families:
- `api_request_completed`
- `api_request_failed`

Each event is emitted with JSON fields suitable for centralized search and incident triage.

## Minimum Incident Triage Fields
| Field | Description | Example |
|---|---|---|
| `timestamp` | UTC event timestamp | `2026-05-03T10:28:00.641Z` |
| `correlationId` | Cross-service request correlation value | `manual-correlation-id-123` |
| `requestId` | Fastify internal request id | `req-4` |
| `method` | HTTP method | `POST` |
| `route` | Route template path | `/api/v1/sessions/:id` |
| `statusCode` | Response status | `429` |
| `userScope` | User visibility scope (`user:<id>` or `anonymous`) | `user:abc123` |
| `event` | Operational event type | `api_request_failed` |
| `errorCode` | Error code (error events only) | `RATE_LIMITED` |
| `errorMessage` | Human-readable message (error events only) | `Too many requests` |

## Correlation ID Policy
- If request header `x-correlation-id` exists, backend reuses it.
- If missing, backend generates fallback from Fastify request id.
- Backend always returns `x-correlation-id` in the response header.

## Error Monitoring Plan

### Tool Choice
- **Primary recommendation:** Sentry (Node SDK) for backend exception and performance issue tracking.
- **Reason:** mature issue grouping, alerting rules, release/environment tagging, and low-friction Fastify/Node integration.

### Integration Steps (Planned)
1. Create Sentry project for backend API with `staging` and `production` environments.
2. Add `SENTRY_DSN` to secret manager (do not commit to `.env.example`).
3. Install Sentry SDK in backend and initialize during app bootstrap.
4. Capture unhandled exceptions and map `requestId`/`correlationId` in event context.
5. Configure alert rules:
   - spike in `5xx` rate,
   - recurring `INTERNAL_ERROR`,
   - sustained `RATE_LIMITED` spikes.
6. Add dashboard links and on-call runbook references.

### Initial Alert Threshold Recommendation
- Trigger alert when `5xx` responses exceed 2% over 5 minutes.
- Trigger warning when `429` exceeds baseline by 3x for 10 minutes.

## Operational Notes
- Keep API error envelope stable: `{ message, code, requestId, details? }`.
- Use logs + correlation ID first for incident triage before deep debugging.
