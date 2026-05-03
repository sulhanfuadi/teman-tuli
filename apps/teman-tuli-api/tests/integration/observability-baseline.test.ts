import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import type { FastifyInstance } from 'fastify';
import { buildApp } from '../../src/app.js';
import { createInMemoryRepositories } from '../support/in-memory-repos.js';

describe('Observability baseline', () => {
  let app: FastifyInstance;

  beforeEach(async () => {
    app = await buildApp(createInMemoryRepositories());
    await app.ready();
  });

  afterEach(async () => {
    await app.close();
  });

  it('returns generated correlation id when client does not provide one', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/health'
    });

    const correlationId = response.headers['x-correlation-id'];

    expect(response.statusCode).toBe(200);
    expect(correlationId).toBeTypeOf('string');
    expect((correlationId as string).length).toBeGreaterThan(0);
  });

  it('echoes client-provided correlation id in response header', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/health',
      headers: {
        'x-correlation-id': 'manual-correlation-id-123'
      }
    });

    expect(response.statusCode).toBe(200);
    expect(response.headers['x-correlation-id']).toBe('manual-correlation-id-123');
  });
});
