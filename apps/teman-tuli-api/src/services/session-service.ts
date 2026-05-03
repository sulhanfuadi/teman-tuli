import type { Repositories } from '../repositories/interfaces.js';
import type { FeedbackRating } from '../types/domain.js';

export class SessionService {
  constructor(private readonly repos: Repositories) {}

  async listSessions(userId: string) {
    return this.repos.transcriptSessions.listByUser(userId);
  }

  async createSession(input: {
    userId: string;
    title: string;
    className?: string | null;
    languageCode: string;
    fullText: string;
    notes?: string | null;
    startedAt: Date;
    endedAt: Date;
    segments: Array<{ text: string; startMs: number; endMs?: number | null }>;
  }) {
    if (!input.fullText.trim()) {
      throw new Error('EMPTY_TRANSCRIPT');
    }
    if (input.endedAt.getTime() < input.startedAt.getTime()) {
      throw new Error('INVALID_TIME_RANGE');
    }

    return this.repos.transcriptSessions.create(input);
  }

  async getSession(id: string, userId: string) {
    const session = await this.repos.transcriptSessions.findByIdForUser(id, userId);
    if (!session) throw new Error('SESSION_NOT_FOUND');
    return session;
  }

  async updateSession(
    id: string,
    userId: string,
    input: { title?: string; className?: string | null; notes?: string | null }
  ) {
    const session = await this.repos.transcriptSessions.updateByIdForUser(id, userId, input);
    if (!session) throw new Error('SESSION_NOT_FOUND');
    return session;
  }

  async deleteSession(id: string, userId: string) {
    const deleted = await this.repos.transcriptSessions.deleteByIdForUser(id, userId);
    if (!deleted) throw new Error('SESSION_NOT_FOUND');
  }

  async createFeedback(input: { id: string; userId: string; rating: FeedbackRating; comment?: string | null }) {
    const session = await this.repos.transcriptSessions.findByIdForUser(input.id, input.userId);
    if (!session) throw new Error('SESSION_NOT_FOUND');

    return this.repos.captionFeedback.create({
      userId: input.userId,
      sessionId: input.id,
      rating: input.rating,
      comment: input.comment ?? null
    });
  }
}
