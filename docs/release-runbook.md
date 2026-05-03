# Teman Tuli Release Runbook (Priority 2.9)

This runbook is designed so another engineer can release and rollback safely without tribal knowledge.

## 1) Pre-Flight Checklist
- [ ] Confirm PR quality gate is green (`npm test`, `npm run build`) from CI.
- [ ] Confirm target commit/tag for deployment is frozen.
- [ ] Confirm environment variables are present (`DATABASE_URL`, `JWT_SECRET`, optional observability vars).
- [ ] Confirm database backup snapshot is available and restorable.
- [ ] Confirm rollback owner and communication channel are assigned.

## 2) Release Sequence (DB + API)
1. Announce deployment window to stakeholders.
2. Apply committed migrations only:
   ```bash
   cd apps/teman-tuli-api
   npm run prisma:deploy
   ```
3. Deploy API service using the target release artifact/commit.
4. Verify service boot and health endpoint:
   ```bash
   curl http://<api-host>/health
   ```
5. Confirm `/docs` and key authenticated routes are reachable.

## 3) Smoke Test Checklist (Post-Deploy)
- [ ] `POST /api/v1/auth/register` works with fresh test account.
- [ ] `POST /api/v1/auth/login` returns token.
- [ ] `POST /api/v1/sessions` saves private transcript.
- [ ] `GET /api/v1/sessions` returns user-scoped data only.
- [ ] `PATCH /api/v1/sessions/:id` updates owner session.
- [ ] `POST /api/v1/sessions/:id/feedback` stores feedback.
- [ ] `DELETE /api/v1/sessions/:id` deletes owner session.

## 4) Rollback Triggers
Rollback is required if one or more conditions occur:
- sustained `5xx` error increase after release,
- authentication failure spike,
- migration-related query failures,
- user-scoped authorization regressions,
- critical data integrity anomaly in transcript session flow.

## 5) Rollback Steps (Operational DB + API)
1. Freeze new deployment activity.
2. Route traffic away from unstable revision (or scale down affected instances).
3. Roll API back to last known good release artifact.
4. If migration caused data or query breakage:
   - restore database from pre-release snapshot,
   - re-point API to restored DB,
   - restart API on last known good revision.
5. Run smoke checks again on rollback revision.
6. Announce rollback completion and incident status.

## 6) Post-Release Verification Checklist
- [ ] Logs show normal request success ratio and stable latency.
- [ ] Error envelope and rate limit behavior remain consistent.
- [ ] No cross-user access regression observed.
- [ ] Observability fields (`requestId`, `correlationId`, `route`, `statusCode`, `userScope`) appear in logs.
- [ ] Incident notes and release notes are documented.

## 7) Artifact Checklist
- [ ] Release commit hash/tag
- [ ] Migration execution logs
- [ ] Smoke test evidence
- [ ] Rollback evidence (if triggered)

## 8) Latest Rehearsal Evidence
- `docs/evidence/iterations/release-rehearsal-2026-05-04.md`
