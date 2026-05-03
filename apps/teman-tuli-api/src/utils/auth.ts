import type { FastifyRequest } from 'fastify';

export const getUserId = (request: FastifyRequest): string => {
  const payload = request.user as { sub?: string };
  if (!payload.sub) {
    throw new Error('INVALID_TOKEN_PAYLOAD');
  }
  return payload.sub;
};
