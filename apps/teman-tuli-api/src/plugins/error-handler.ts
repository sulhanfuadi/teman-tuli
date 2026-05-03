import type { FastifyInstance } from 'fastify';
import { sendApiError } from '../utils/api-error.js';

export const registerErrorHandler = (app: FastifyInstance) => {
  app.setErrorHandler((error, request, reply) => {
    if (reply.sent) {
      return;
    }

    const errorCode = (error as { code?: string }).code;
    const statusCode = (error as { statusCode?: number }).statusCode;
    const validation = (error as { validation?: unknown }).validation;
    const errorMessage = error instanceof Error ? error.message : '';

    if (validation) {
      return sendApiError(reply, {
        statusCode: 400,
        message: 'Invalid request payload',
        code: 'VALIDATION_ERROR',
        details: validation
      });
    }

    if (statusCode === 413 || errorCode === 'FST_ERR_CTP_BODY_TOO_LARGE') {
      return sendApiError(reply, {
        statusCode: 413,
        message: 'Payload too large',
        code: 'PAYLOAD_TOO_LARGE'
      });
    }

    if (statusCode === 429 || errorCode === 'FST_ERR_RATE_LIMIT') {
      return sendApiError(reply, {
        statusCode: 429,
        message: 'Too many requests',
        code: 'RATE_LIMITED'
      });
    }

    if (statusCode === 401) {
      return sendApiError(reply, {
        statusCode: 401,
        message: 'Unauthorized',
        code: 'UNAUTHORIZED'
      });
    }

    if (statusCode === 404) {
      return sendApiError(reply, {
        statusCode: 404,
        message: errorMessage || 'Not found',
        code: 'NOT_FOUND'
      });
    }

    if (statusCode === 409) {
      return sendApiError(reply, {
        statusCode: 409,
        message: errorMessage || 'Conflict',
        code: 'CONFLICT'
      });
    }

    if (statusCode && statusCode >= 400 && statusCode < 500) {
      return sendApiError(reply, {
        statusCode,
        message: errorMessage || 'Bad request',
        code: 'BAD_REQUEST'
      });
    }

    request.log.error({ err: error }, 'Unhandled API error');

    return sendApiError(reply, {
      statusCode: 500,
      message: 'Internal server error',
      code: 'INTERNAL_ERROR'
    });
  });
};
