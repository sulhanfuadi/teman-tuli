import type { FastifyInstance, FastifyRequest } from 'fastify';

const getUserScope = (request: FastifyRequest): string => {
  const user = request.user;

  if (user && typeof user === 'object' && !Buffer.isBuffer(user) && 'sub' in user && typeof user.sub === 'string') {
    return `user:${user.sub}`;
  }

  return 'anonymous';
};

const getRoutePath = (request: FastifyRequest): string => {
  return request.routeOptions.url ?? 'unknown-route';
};

export const registerObservability = (app: FastifyInstance) => {
  app.addHook('onRequest', async (request, reply) => {
    const headerCorrelationId = request.headers['x-correlation-id'];
    const correlationId =
      typeof headerCorrelationId === 'string' && headerCorrelationId.trim().length > 0
        ? headerCorrelationId
        : request.id;

    request.correlationId = correlationId;
    reply.header('x-correlation-id', correlationId);
  });

  app.addHook('onResponse', async (request, reply) => {
    app.log.info({
      event: 'api_request_completed',
      correlationId: request.correlationId ?? request.id,
      requestId: request.id,
      timestamp: new Date().toISOString(),
      method: request.method,
      route: getRoutePath(request),
      statusCode: reply.statusCode,
      userScope: getUserScope(request)
    });
  });

  app.addHook('onError', async (request, reply, error) => {
    app.log.error({
      event: 'api_request_failed',
      correlationId: request.correlationId ?? request.id,
      requestId: request.id,
      timestamp: new Date().toISOString(),
      method: request.method,
      route: getRoutePath(request),
      statusCode: reply.statusCode,
      userScope: getUserScope(request),
      errorCode: (error as { code?: string }).code ?? 'UNKNOWN',
      errorMessage: error.message
    });
  });
};
