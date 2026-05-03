import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { AuthService } from '../services/auth-service.js';
import { sendApiError } from '../utils/api-error.js';

const registerSchema = z.object({
  name: z.string().min(2),
  email: z.string().email(),
  password: z.string().min(8),
  goal: z.string().min(3).max(300).optional()
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8)
});

export const registerAuthRoutes = async (app: FastifyInstance) => {
  const authService = new AuthService(app.repos);

  app.post('/auth/register', {
    bodyLimit: 16 * 1024,
    config: {
      rateLimit: {
        max: 8,
        timeWindow: '1 minute'
      }
    },
    schema: {
      tags: ['Auth'],
      body: {
        type: 'object',
        required: ['name', 'email', 'password'],
        properties: {
          name: { type: 'string' },
          email: { type: 'string', format: 'email' },
          password: { type: 'string', minLength: 8 },
          goal: { type: 'string' }
        }
      }
    }
  }, async (request, reply) => {
    const parsed = registerSchema.safeParse(request.body);
    if (!parsed.success) {
      return sendApiError(reply, {
        statusCode: 400,
        message: 'Invalid request payload',
        code: 'VALIDATION_ERROR',
        details: parsed.error.flatten()
      });
    }

    try {
      const user = await authService.register(parsed.data);
      const token = await reply.jwtSign({ sub: user.id, email: user.email, name: user.name });
      return reply.code(201).send({ user, token });
    } catch (error) {
      if (error instanceof Error && error.message === 'EMAIL_ALREADY_USED') {
        return sendApiError(reply, {
          statusCode: 409,
          message: 'Email already used',
          code: 'CONFLICT'
        });
      }
      throw error;
    }
  });

  app.post('/auth/login', {
    bodyLimit: 16 * 1024,
    config: {
      rateLimit: {
        max: 8,
        timeWindow: '1 minute'
      }
    },
    schema: {
      tags: ['Auth'],
      body: {
        type: 'object',
        required: ['email', 'password'],
        properties: {
          email: { type: 'string', format: 'email' },
          password: { type: 'string', minLength: 8 }
        }
      }
    }
  }, async (request, reply) => {
    const parsed = loginSchema.safeParse(request.body);
    if (!parsed.success) {
      return sendApiError(reply, {
        statusCode: 400,
        message: 'Invalid request payload',
        code: 'VALIDATION_ERROR',
        details: parsed.error.flatten()
      });
    }

    try {
      const user = await authService.login(parsed.data);
      const token = await reply.jwtSign({ sub: user.id, email: user.email, name: user.name });
      return reply.send({ user, token });
    } catch (error) {
      if (error instanceof Error && error.message === 'INVALID_CREDENTIALS') {
        return sendApiError(reply, {
          statusCode: 401,
          message: 'Invalid credentials',
          code: 'UNAUTHORIZED'
        });
      }
      throw error;
    }
  });
};
