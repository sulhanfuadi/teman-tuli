import type { FastifyInstance, FastifyReply, FastifyRequest } from 'fastify';

export const registerAuthHook = (app: FastifyInstance) => {
  app.decorate('authenticate', async (request: FastifyRequest, reply: FastifyReply) => {
    try {
      await request.jwtVerify();
    } catch {
      reply.code(401).send({ message: 'Unauthorized' });
    }
  });
};
