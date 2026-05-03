import { PrismaClient } from '@prisma/client';
import type { Repositories } from './interfaces.js';

export const prisma = new PrismaClient();

export const createPrismaRepositories = (client: PrismaClient = prisma): Repositories => ({
  users: {
    create: (input) =>
      client.user.create({
        data: {
          name: input.name,
          email: input.email,
          passwordHash: input.passwordHash,
          goal: input.goal
        }
      }),
    findByEmail: (email) => client.user.findUnique({ where: { email } }),
    findById: (id) => client.user.findUnique({ where: { id } })
  },
  transcriptSessions: {
    listByUser: (userId) =>
      client.transcriptSession.findMany({
        where: { userId },
        orderBy: { startedAt: 'desc' },
        include: { segments: { orderBy: { startMs: 'asc' } } }
      }),
    create: (input) =>
      client.transcriptSession.create({
        data: {
          userId: input.userId,
          title: input.title,
          className: input.className ?? null,
          languageCode: input.languageCode,
          fullText: input.fullText,
          notes: input.notes ?? null,
          startedAt: input.startedAt,
          endedAt: input.endedAt,
          segments: {
            create: input.segments.map((segment) => ({
              text: segment.text,
              startMs: segment.startMs,
              endMs: segment.endMs ?? null
            }))
          }
        },
        include: { segments: { orderBy: { startMs: 'asc' } } }
      }),
    findByIdForUser: (id, userId) =>
      client.transcriptSession.findFirst({
        where: { id, userId },
        include: { segments: { orderBy: { startMs: 'asc' } } }
      }),
    updateByIdForUser: (id, userId, input) =>
      client.transcriptSession.updateMany({ where: { id, userId }, data: input }).then(async (result) => {
        if (result.count === 0) return null;
        return client.transcriptSession.findUnique({
          where: { id },
          include: { segments: { orderBy: { startMs: 'asc' } } }
        });
      }),
    deleteByIdForUser: (id, userId) =>
      client.transcriptSession.deleteMany({ where: { id, userId } }).then((result) => result.count > 0)
  },
  captionFeedback: {
    create: (input) => client.captionFeedback.create({ data: input })
  }
});
