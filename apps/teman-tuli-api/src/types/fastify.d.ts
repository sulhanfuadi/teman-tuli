import 'fastify';

declare module 'fastify' {
  interface FastifyRequest {
    correlationId?: string;
    user: {
      sub: string;
      email: string;
      name: string;
    };
  }
}
