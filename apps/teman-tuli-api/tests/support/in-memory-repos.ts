import type {
  CaptionFeedbackRecord,
  FeedbackRating,
  TranscriptSegmentRecord,
  TranscriptSessionRecord,
  UserRecord
} from '../../src/types/domain.js';
import type { Repositories } from '../../src/repositories/interfaces.js';

const cuid = () => Math.random().toString(36).slice(2, 12);

export const createInMemoryRepositories = (): Repositories => {
  const users: UserRecord[] = [];
  const sessions: TranscriptSessionRecord[] = [];
  const feedback: CaptionFeedbackRecord[] = [];

  return {
    users: {
      async create(input) {
        const record: UserRecord = {
          id: cuid(),
          name: input.name,
          email: input.email,
          passwordHash: input.passwordHash,
          goal: input.goal ?? null
        };
        users.push(record);
        return record;
      },
      async findByEmail(email) {
        return users.find((user) => user.email === email) ?? null;
      },
      async findById(id) {
        return users.find((user) => user.id === id) ?? null;
      }
    },
    transcriptSessions: {
      async listByUser(userId) {
        return sessions.filter((session) => session.userId === userId);
      },
      async create(input) {
        const now = new Date();
        const id = cuid();
        const segments: TranscriptSegmentRecord[] = input.segments.map((segment) => ({
          id: cuid(),
          sessionId: id,
          text: segment.text,
          startMs: segment.startMs,
          endMs: segment.endMs ?? null
        }));
        const record: TranscriptSessionRecord = {
          id,
          userId: input.userId,
          title: input.title,
          className: input.className ?? null,
          languageCode: input.languageCode,
          fullText: input.fullText,
          notes: input.notes ?? null,
          startedAt: input.startedAt,
          endedAt: input.endedAt,
          createdAt: now,
          updatedAt: now,
          segments
        };
        sessions.push(record);
        return record;
      },
      async findByIdForUser(id, userId) {
        return sessions.find((session) => session.id === id && session.userId === userId) ?? null;
      },
      async updateByIdForUser(id, userId, input) {
        const session = sessions.find((entry) => entry.id === id && entry.userId === userId);
        if (!session) return null;
        if (input.title !== undefined) session.title = input.title;
        if (input.className !== undefined) session.className = input.className;
        if (input.notes !== undefined) session.notes = input.notes;
        session.updatedAt = new Date();
        return session;
      },
      async deleteByIdForUser(id, userId) {
        const index = sessions.findIndex((session) => session.id === id && session.userId === userId);
        if (index === -1) return false;
        sessions.splice(index, 1);
        return true;
      }
    },
    captionFeedback: {
      async create(input) {
        const record: CaptionFeedbackRecord = {
          id: cuid(),
          userId: input.userId,
          sessionId: input.sessionId,
          rating: input.rating as FeedbackRating,
          comment: input.comment ?? null,
          createdAt: new Date()
        };
        feedback.push(record);
        return record;
      }
    }
  };
};
