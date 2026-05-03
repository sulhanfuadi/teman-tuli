import type { FastifyInstance, FastifyRequest } from 'fastify';
import { z } from 'zod';
import { SessionService } from '../services/session-service.js';
import { getUserId } from '../utils/auth.js';
import { sendApiError } from '../utils/api-error.js';

const segmentSchema = z.object({
  text: z.string().min(1).max(300),
  startMs: z.number().int().min(0),
  endMs: z.number().int().min(0).nullable().optional()
});

const createSessionSchema = z.object({
  title: z.string().min(2).max(120),
  className: z.string().max(120).nullable().optional(),
  languageCode: z.string().min(2).default('id-ID'),
  fullText: z.string().min(1).max(20_000),
  notes: z.string().max(1000).nullable().optional(),
  startedAt: z.string().datetime(),
  endedAt: z.string().datetime(),
  segments: z.array(segmentSchema).max(500).default([])
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

const writeRateLimit = {
  max: 30,
  timeWindow: '1 minute',
  keyGenerator: (request: FastifyRequest) => {
    const user = request.user;
    const userId =
      user &&
      typeof user === 'object' &&
      !Buffer.isBuffer(user) &&
      'sub' in user &&
      typeof user.sub === 'string'
        ? user.sub
        : undefined;

    return userId ? `user:${userId}` : `ip:${request.ip}`;
  }
};

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
    bodyLimit: 512 * 1024,
    config: {
      rateLimit: writeRateLimit
    },
    preHandler: [app.authenticate],
    schema: {
      tags: ['Transcript Sessions'],
      security: [{ bearerAuth: [] }]
    }
  }, async (request, reply) => {
    const parsed = createSessionSchema.safeParse(request.body);
    if (!parsed.success) {
      return sendApiError(reply, {
        statusCode: 400,
        message: 'Invalid request payload',
        code: 'VALIDATION_ERROR',
        details: parsed.error.flatten()
      });
    }

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
        return sendApiError(reply, {
          statusCode: 400,
          message: error.message,
          code: 'BAD_REQUEST'
        });
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
    if (!params.success) {
      return sendApiError(reply, {
        statusCode: 400,
        message: 'Invalid session id',
        code: 'VALIDATION_ERROR',
        details: params.error.flatten()
      });
    }

    try {
      return await service.getSession(params.data.id, getUserId(request));
    } catch (error) {
      if (error instanceof Error && error.message === 'SESSION_NOT_FOUND') {
        return sendApiError(reply, {
          statusCode: 404,
          message: 'Session not found',
          code: 'NOT_FOUND'
        });
      }
      throw error;
    }
  });

  app.patch('/sessions/:id', {
    bodyLimit: 64 * 1024,
    config: {
      rateLimit: writeRateLimit
    },
    preHandler: [app.authenticate],
    schema: {
      tags: ['Transcript Sessions'],
      security: [{ bearerAuth: [] }]
    }
  }, async (request, reply) => {
    const params = paramsSchema.safeParse(request.params);
    const body = updateSessionSchema.safeParse(request.body);
    if (!params.success || !body.success) {
      return sendApiError(reply, {
        statusCode: 400,
        message: 'Invalid request payload',
        code: 'VALIDATION_ERROR',
        details: {
          params: params.success ? undefined : params.error.flatten(),
          body: body.success ? undefined : body.error.flatten()
        }
      });
    }

    try {
      return await service.updateSession(params.data.id, getUserId(request), body.data);
    } catch (error) {
      if (error instanceof Error && error.message === 'SESSION_NOT_FOUND') {
        return sendApiError(reply, {
          statusCode: 404,
          message: 'Session not found',
          code: 'NOT_FOUND'
        });
      }
      throw error;
    }
  });

  app.delete('/sessions/:id', {
    config: {
      rateLimit: writeRateLimit
    },
    preHandler: [app.authenticate],
    schema: {
      tags: ['Transcript Sessions'],
      security: [{ bearerAuth: [] }]
    }
  }, async (request, reply) => {
    const params = paramsSchema.safeParse(request.params);
    if (!params.success) {
      return sendApiError(reply, {
        statusCode: 400,
        message: 'Invalid session id',
        code: 'VALIDATION_ERROR',
        details: params.error.flatten()
      });
    }

    try {
      await service.deleteSession(params.data.id, getUserId(request));
      return reply.code(204).send();
    } catch (error) {
      if (error instanceof Error && error.message === 'SESSION_NOT_FOUND') {
        return sendApiError(reply, {
          statusCode: 404,
          message: 'Session not found',
          code: 'NOT_FOUND'
        });
      }
      throw error;
    }
  });

  app.post('/sessions/:id/feedback', {
    bodyLimit: 64 * 1024,
    config: {
      rateLimit: writeRateLimit
    },
    preHandler: [app.authenticate],
    schema: {
      tags: ['Caption Feedback'],
      security: [{ bearerAuth: [] }]
    }
  }, async (request, reply) => {
    const params = paramsSchema.safeParse(request.params);
    const body = feedbackSchema.safeParse(request.body);
    if (!params.success || !body.success) {
      return sendApiError(reply, {
        statusCode: 400,
        message: 'Invalid request payload',
        code: 'VALIDATION_ERROR',
        details: {
          params: params.success ? undefined : params.error.flatten(),
          body: body.success ? undefined : body.error.flatten()
        }
      });
    }

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
        return sendApiError(reply, {
          statusCode: 404,
          message: 'Session not found',
          code: 'NOT_FOUND'
        });
      }
      throw error;
    }
  });
};
