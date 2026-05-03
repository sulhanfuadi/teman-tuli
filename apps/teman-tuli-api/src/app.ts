import Fastify, { type FastifyInstance, type FastifyReply, type FastifyRequest } from 'fastify';
import cors from '@fastify/cors';
import fastifyJwt from '@fastify/jwt';
import fastifyRateLimit from '@fastify/rate-limit';
import { env } from './config/env.js';
import { registerSwagger } from './plugins/swagger.js';
import { registerAuthHook } from './plugins/auth.js';
import { registerErrorHandler } from './plugins/error-handler.js';
import { createPrismaRepositories } from './repositories/prisma.js';
import type { Repositories } from './repositories/interfaces.js';
import { registerAuthRoutes } from './routes/auth-routes.js';
import { registerSessionRoutes } from './routes/session-routes.js';

declare module 'fastify' {
  interface FastifyInstance {
    authenticate: (request: FastifyRequest, reply: FastifyReply) => Promise<void>;
    repos: Repositories;
  }
}

export const buildApp = async (repositories?: Repositories): Promise<FastifyInstance> => {
  const app = Fastify({ logger: true });

  await app.register(cors, { origin: true });
  await app.register(fastifyJwt, { secret: env.JWT_SECRET });
  await app.register(fastifyRateLimit, {
    global: false,
    hook: 'preHandler',
    errorResponseBuilder: (request) => ({
      message: 'Too many requests',
      code: 'RATE_LIMITED',
      requestId: request.id
    })
  });
  await registerSwagger(app);

  app.decorate('repos', repositories ?? createPrismaRepositories());
  registerAuthHook(app);

  await app.register(async (api) => {
    await registerAuthRoutes(api);
    await registerSessionRoutes(api);
  }, { prefix: '/api/v1' });

  registerErrorHandler(app);

  app.get('/health', async () => ({ ok: true, service: 'teman-tuli-backend' }));

  return app;
};
