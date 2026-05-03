import type { FastifyReply } from 'fastify';

export type ApiErrorCode =
  | 'VALIDATION_ERROR'
  | 'UNAUTHORIZED'
  | 'NOT_FOUND'
  | 'CONFLICT'
  | 'PAYLOAD_TOO_LARGE'
  | 'RATE_LIMITED'
  | 'INTERNAL_ERROR'
  | 'BAD_REQUEST';

export const sendApiError = (
  reply: FastifyReply,
  input: {
    statusCode: number;
    message: string;
    code: ApiErrorCode;
    details?: unknown;
  }
) => {
  return reply.code(input.statusCode).send({
    message: input.message,
    code: input.code,
    requestId: reply.request.id,
    ...(input.details !== undefined ? { details: input.details } : {})
  });
};

