import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { buildApp } from '../../src/app.js';
import { createInMemoryRepositories } from '../support/in-memory-repos.js';

const buildPayloadSession = () => {
  const startedAt = new Date('2026-05-03T01:00:00.000Z').toISOString();
  const endedAt = new Date('2026-05-03T01:20:00.000Z').toISOString();

  return {
    title: 'Kuliah Resilience Testing',
    className: 'Apple Foundation Prep',
    languageCode: 'id-ID',
    fullText: 'Caption baseline text.',
    startedAt,
    endedAt,
    segments: [{ text: 'Caption baseline text.', startMs: 0, endMs: 1500 }]
  };
};

describe('API resilience safeguards', () => {
  let app: FastifyInstance;

  beforeEach(async () => {
    app = await buildApp(createInMemoryRepositories());
    await app.ready();
  });

  afterEach(async () => {
    await app.close();
  });

  it('returns standardized validation error envelope for malformed auth payload', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/api/v1/auth/register',
      payload: {
        email: 'missing-name@example.com'
      }
    });

    expect(response.statusCode).toBe(400);
    const body = response.json();
    expect(body.message).toBeTypeOf('string');
    expect(body.code).toBe('VALIDATION_ERROR');
    expect(body.requestId).toBeTypeOf('string');
  });

  it('returns PAYLOAD_TOO_LARGE for oversized auth body', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/api/v1/auth/register',
      payload: {
        name: 'Payload Tester',
        email: 'payload@example.com',
        password: 'password123',
        goal: 'A'.repeat(17 * 1024)
      }
    });

    expect(response.statusCode).toBe(413);
    const body = response.json();
    expect(body.code).toBe('PAYLOAD_TOO_LARGE');
    expect(body.requestId).toBeTypeOf('string');
  });

  it('returns PAYLOAD_TOO_LARGE for oversized session create body', async () => {
    const register = await app.inject({
      method: 'POST',
      url: '/api/v1/auth/register',
      payload: {
        name: 'Session Payload Tester',
        email: 'session-payload@example.com',
        password: 'password123'
      }
    });

    const token = register.json().token as string;

    const response = await app.inject({
      method: 'POST',
      url: '/api/v1/sessions',
      headers: { authorization: `Bearer ${token}` },
      payload: {
        ...buildPayloadSession(),
        fullText: 'B'.repeat(600 * 1024)
      }
    });

    expect(response.statusCode).toBe(413);
    const body = response.json();
    expect(body.code).toBe('PAYLOAD_TOO_LARGE');
    expect(body.requestId).toBeTypeOf('string');
  });

  it('applies auth rate limit after repeated login attempts', async () => {
    await app.inject({
      method: 'POST',
      url: '/api/v1/auth/register',
      payload: {
        name: 'Rate Limit User',
        email: 'rate-limit@example.com',
        password: 'password123'
      }
    });

    let lastResponse = await app.inject({
      method: 'POST',
      url: '/api/v1/auth/login',
      payload: {
        email: 'rate-limit@example.com',
        password: 'wrong-password'
      }
    });

    for (let attempt = 0; attempt < 8; attempt += 1) {
      lastResponse = await app.inject({
        method: 'POST',
        url: '/api/v1/auth/login',
        payload: {
          email: 'rate-limit@example.com',
          password: 'wrong-password'
        }
      });
    }

    expect(lastResponse.statusCode).toBe(429);
    const body = lastResponse.json();
    expect(body.code).toBe('RATE_LIMITED');
    expect(body.requestId).toBeTypeOf('string');
  });

  it('applies write route rate limit for authenticated user', async () => {
    const register = await app.inject({
      method: 'POST',
      url: '/api/v1/auth/register',
      payload: {
        name: 'Write Limit User',
        email: 'write-limit@example.com',
        password: 'password123'
      }
    });

    const token = register.json().token as string;

    const created = await app.inject({
      method: 'POST',
      url: '/api/v1/sessions',
      headers: { authorization: `Bearer ${token}` },
      payload: buildPayloadSession()
    });

    const sessionId = created.json().id as string;

    let rateLimitedResponse = null as null | Awaited<ReturnType<typeof app.inject>>;

    for (let attempt = 0; attempt < 31; attempt += 1) {
      const response = await app.inject({
        method: 'PATCH',
        url: `/api/v1/sessions/${sessionId}`,
        headers: { authorization: `Bearer ${token}` },
        payload: {
          notes: `Update note ${attempt}`
        }
      });

      if (response.statusCode === 429) {
        rateLimitedResponse = response;
        break;
      }
    }

    expect(rateLimitedResponse).not.toBeNull();
    const body = rateLimitedResponse?.json();
    expect(body?.code).toBe('RATE_LIMITED');
    expect(body?.requestId).toBeTypeOf('string');
  });

  it('keeps standardized domain errors for conflict, unauthorized, and not found', async () => {
    const register = await app.inject({
      method: 'POST',
      url: '/api/v1/auth/register',
      payload: {
        name: 'Domain Error User',
        email: 'domain-errors@example.com',
        password: 'password123'
      }
    });

    const token = register.json().token as string;

    const duplicateRegister = await app.inject({
      method: 'POST',
      url: '/api/v1/auth/register',
      payload: {
        name: 'Domain Error User',
        email: 'domain-errors@example.com',
        password: 'password123'
      }
    });

    expect(duplicateRegister.statusCode).toBe(409);
    expect(duplicateRegister.json().code).toBe('CONFLICT');
    expect(duplicateRegister.json().requestId).toBeTypeOf('string');

    const invalidLogin = await app.inject({
      method: 'POST',
      url: '/api/v1/auth/login',
      payload: {
        email: 'domain-errors@example.com',
        password: 'wrong-password'
      }
    });

    expect(invalidLogin.statusCode).toBe(401);
    expect(invalidLogin.json().code).toBe('UNAUTHORIZED');
    expect(invalidLogin.json().requestId).toBeTypeOf('string');

    const missingSession = await app.inject({
      method: 'GET',
      url: '/api/v1/sessions/non-existent-id',
      headers: { authorization: `Bearer ${token}` }
    });

    expect(missingSession.statusCode).toBe(404);
    expect(missingSession.json().code).toBe('NOT_FOUND');
    expect(missingSession.json().requestId).toBeTypeOf('string');
  });
});
