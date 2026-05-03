import { describe, expect, it } from 'vitest';
import { SessionService } from '../../src/services/session-service.js';
import { createInMemoryRepositories } from '../support/in-memory-repos.js';

describe('SessionService', () => {
  it('creates private transcript sessions with timestamped segments', async () => {
    const service = new SessionService(createInMemoryRepositories());
    const startedAt = new Date('2026-05-03T01:00:00.000Z');
    const endedAt = new Date('2026-05-03T01:30:00.000Z');

    const session = await service.createSession({
      userId: 'user-1',
      title: 'Inclusive Design Lecture',
      className: 'UX Research',
      languageCode: 'id-ID',
      fullText: 'Selamat pagi teman-teman.',
      startedAt,
      endedAt,
      segments: [{ text: 'Selamat pagi teman-teman.', startMs: 0, endMs: 2400 }]
    });

    expect(session.title).toBe('Inclusive Design Lecture');
    expect(session.segments).toHaveLength(1);
  });

  it('rejects empty transcripts', async () => {
    const service = new SessionService(createInMemoryRepositories());

    await expect(service.createSession({
      userId: 'user-1',
      title: 'Empty',
      languageCode: 'id-ID',
      fullText: '   ',
      startedAt: new Date(),
      endedAt: new Date(),
      segments: []
    })).rejects.toThrow('EMPTY_TRANSCRIPT');
  });
});
