import type { FastifyInstance, FastifyReply, FastifyRequest } from 'fastify';
import { sendApiError } from '../utils/api-error.js';

export const registerAuthHook = (app: FastifyInstance) => {
  app.decorate('authenticate', async (request: FastifyRequest, reply: FastifyReply) => {
    try {
      await request.jwtVerify();
    } catch {
      return sendApiError(reply, {
        statusCode: 401,
        message: 'Unauthorized',
        code: 'UNAUTHORIZED'
      });
    }
  });
};
