import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { SessionService } from '../services/session-service.js';
import { getUserId } from '../utils/auth.js';

const segmentSchema = z.object({
  text: z.string().min(1),
  startMs: z.number().int().min(0),
  endMs: z.number().int().min(0).nullable().optional()
});

const createSessionSchema = z.object({
  title: z.string().min(2).max(120),
  className: z.string().max(120).nullable().optional(),
  languageCode: z.string().min(2).default('id-ID'),
  fullText: z.string().min(1),
  notes: z.string().max(1000).nullable().optional(),
  startedAt: z.string().datetime(),
  endedAt: z.string().datetime(),
  segments: z.array(segmentSchema).default([])
});

const updateSessionSchema = z.object({
  title: z.string().min(2).max(120).optional(),
  className: z.string().max(120).nullable().optional(),
  notes: z.string().max(1000).nullable().optional()
});

const feedbackSchema = z.object({
  rating: z.enum(['POOR', 'OKAY', 'GOOD', 'EXCELLENT']),
  comment: z.string().max(500).nullable().optional()
});

const paramsSchema = z.object({ id: z.string().min(1) });

export const registerSessionRoutes = async (app: FastifyInstance) => {
  const service = new SessionService(app.repos);

  app.get('/sessions', {
    preHandler: [app.authenticate],
    schema: {
      tags: ['Transcript Sessions'],
      security: [{ bearerAuth: [] }]
    }
  }, async (request) => service.listSessions(getUserId(request)));

  app.post('/sessions', {
    preHandler: [app.authenticate],
    schema: {
      tags: ['Transcript Sessions'],
      security: [{ bearerAuth: [] }]
    }
  }, async (request, reply) => {
    const parsed = createSessionSchema.safeParse(request.body);
    if (!parsed.success) return reply.code(400).send({ message: parsed.error.flatten() });

    try {
      const session = await service.createSession({
        userId: getUserId(request),
        title: parsed.data.title,
        className: parsed.data.className ?? null,
        languageCode: parsed.data.languageCode,
        fullText: parsed.data.fullText,
        notes: parsed.data.notes ?? null,
        startedAt: new Date(parsed.data.startedAt),
        endedAt: new Date(parsed.data.endedAt),
        segments: parsed.data.segments
      });
      return reply.code(201).send(session);
    } catch (error) {
      if (error instanceof Error && ['EMPTY_TRANSCRIPT', 'INVALID_TIME_RANGE'].includes(error.message)) {
        return reply.code(400).send({ message: error.message });
      }
      throw error;
    }
  });

  app.get('/sessions/:id', {
    preHandler: [app.authenticate],
    schema: {
      tags: ['Transcript Sessions'],
      security: [{ bearerAuth: [] }]
    }
  }, async (request, reply) => {
    const params = paramsSchema.safeParse(request.params);
    if (!params.success) return reply.code(400).send({ message: 'Invalid session id' });

    try {
      return await service.getSession(params.data.id, getUserId(request));
    } catch (error) {
      if (error instanceof Error && error.message === 'SESSION_NOT_FOUND') {
        return reply.code(404).send({ message: 'Session not found' });
      }
      throw error;
    }
  });

  app.patch('/sessions/:id', {
    preHandler: [app.authenticate],
    schema: {
      tags: ['Transcript Sessions'],
      security: [{ bearerAuth: [] }]
    }
  }, async (request, reply) => {
    const params = paramsSchema.safeParse(request.params);
    const body = updateSessionSchema.safeParse(request.body);
    if (!params.success || !body.success) return reply.code(400).send({ message: 'Invalid request' });

    try {
      return await service.updateSession(params.data.id, getUserId(request), body.data);
    } catch (error) {
      if (error instanceof Error && error.message === 'SESSION_NOT_FOUND') {
        return reply.code(404).send({ message: 'Session not found' });
      }
      throw error;
    }
  });

  app.delete('/sessions/:id', {
    preHandler: [app.authenticate],
    schema: {
      tags: ['Transcript Sessions'],
      security: [{ bearerAuth: [] }]
    }
  }, async (request, reply) => {
    const params = paramsSchema.safeParse(request.params);
    if (!params.success) return reply.code(400).send({ message: 'Invalid session id' });

    try {
      await service.deleteSession(params.data.id, getUserId(request));
      return reply.code(204).send();
    } catch (error) {
      if (error instanceof Error && error.message === 'SESSION_NOT_FOUND') {
        return reply.code(404).send({ message: 'Session not found' });
      }
      throw error;
    }
  });

  app.post('/sessions/:id/feedback', {
    preHandler: [app.authenticate],
    schema: {
      tags: ['Caption Feedback'],
      security: [{ bearerAuth: [] }]
    }
  }, async (request, reply) => {
    const params = paramsSchema.safeParse(request.params);
    const body = feedbackSchema.safeParse(request.body);
    if (!params.success || !body.success) return reply.code(400).send({ message: 'Invalid request' });

    try {
      const feedback = await service.createFeedback({
        id: params.data.id,
        userId: getUserId(request),
        rating: body.data.rating,
        comment: body.data.comment ?? null
      });
      return reply.code(201).send(feedback);
    } catch (error) {
      if (error instanceof Error && error.message === 'SESSION_NOT_FOUND') {
        return reply.code(404).send({ message: 'Session not found' });
      }
      throw error;
    }
  });
};
