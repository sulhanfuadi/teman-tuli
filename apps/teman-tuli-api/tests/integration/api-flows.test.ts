import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { buildApp } from '../../src/app.js';
import { createInMemoryRepositories } from '../support/in-memory-repos.js';

describe('Teman Tuli API flows', () => {
  let app: FastifyInstance;
  let token: string;
  let otherToken: string;
  let sessionId: string;

  beforeAll(async () => {
    app = await buildApp(createInMemoryRepositories());
    await app.ready();

    const registerResponse = await app.inject({
      method: 'POST',
      url: '/api/v1/auth/register',
      payload: {
        name: 'Tuli Student',
        email: 'student@example.com',
        password: 'password123'
      }
    });
    token = registerResponse.json().token;

    const otherResponse = await app.inject({
      method: 'POST',
      url: '/api/v1/auth/register',
      payload: {
        name: 'Other Student',
        email: 'other@example.com',
        password: 'password123'
      }
    });
    otherToken = otherResponse.json().token;
  });

  afterAll(async () => {
    await app.close();
  });

  it('saves, lists, reads, updates, and gives feedback on a private transcript', async () => {
    const startedAt = new Date('2026-05-03T01:00:00.000Z');
    const endedAt = new Date('2026-05-03T01:20:00.000Z');

    const createResponse = await app.inject({
      method: 'POST',
      url: '/api/v1/sessions',
      headers: { authorization: `Bearer ${token}` },
      payload: {
        title: 'Kuliah Design Thinking',
        className: 'Apple Foundation Prep',
        languageCode: 'id-ID',
        fullText: 'Hari ini kita belajar empati dalam design thinking.',
        startedAt: startedAt.toISOString(),
        endedAt: endedAt.toISOString(),
        segments: [
          { text: 'Hari ini kita belajar empati', startMs: 0, endMs: 2200 },
          { text: 'dalam design thinking.', startMs: 2300, endMs: 4100 }
        ]
      }
    });

    expect(createResponse.statusCode).toBe(201);
    sessionId = createResponse.json().id;

    const listResponse = await app.inject({
      method: 'GET',
      url: '/api/v1/sessions',
      headers: { authorization: `Bearer ${token}` }
    });
    expect(listResponse.json()).toHaveLength(1);

    const detailResponse = await app.inject({
      method: 'GET',
      url: `/api/v1/sessions/${sessionId}`,
      headers: { authorization: `Bearer ${token}` }
    });
    expect(detailResponse.json().segments).toHaveLength(2);

    const updateResponse = await app.inject({
      method: 'PATCH',
      url: `/api/v1/sessions/${sessionId}`,
      headers: { authorization: `Bearer ${token}` },
      payload: { notes: 'Bagian empathy map penting untuk produk.' }
    });
    expect(updateResponse.json().notes).toContain('empathy map');

    const feedbackResponse = await app.inject({
      method: 'POST',
      url: `/api/v1/sessions/${sessionId}/feedback`,
      headers: { authorization: `Bearer ${token}` },
      payload: { rating: 'GOOD', comment: 'Caption cukup jelas.' }
    });
    expect(feedbackResponse.statusCode).toBe(201);
  });

  it('prevents another user from accessing a private transcript', async () => {
    const forbiddenResponse = await app.inject({
      method: 'GET',
      url: `/api/v1/sessions/${sessionId}`,
      headers: { authorization: `Bearer ${otherToken}` }
    });

    expect(forbiddenResponse.statusCode).toBe(404);
  });

  it('deletes private transcript sessions', async () => {
    const deleteResponse = await app.inject({
      method: 'DELETE',
      url: `/api/v1/sessions/${sessionId}`,
      headers: { authorization: `Bearer ${token}` }
    });

    expect(deleteResponse.statusCode).toBe(204);
  });
});
