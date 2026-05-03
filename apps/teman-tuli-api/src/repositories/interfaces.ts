import type {
  CaptionFeedbackRecord,
  FeedbackRating,
  TranscriptSessionRecord,
  UserRecord
} from '../types/domain.js';

export interface UserRepo {
  create(input: { name: string; email: string; passwordHash: string; goal?: string }): Promise<UserRecord>;
  findByEmail(email: string): Promise<UserRecord | null>;
  findById(id: string): Promise<UserRecord | null>;
}

export interface TranscriptSessionRepo {
  listByUser(userId: string): Promise<TranscriptSessionRecord[]>;
  create(input: {
    userId: string;
    title: string;
    className?: string | null;
    languageCode: string;
    fullText: string;
    notes?: string | null;
    startedAt: Date;
    endedAt: Date;
    segments: Array<{ text: string; startMs: number; endMs?: number | null }>;
  }): Promise<TranscriptSessionRecord>;
  findByIdForUser(id: string, userId: string): Promise<TranscriptSessionRecord | null>;
  updateByIdForUser(
    id: string,
    userId: string,
    input: Partial<Pick<TranscriptSessionRecord, 'title' | 'className' | 'notes'>>
  ): Promise<TranscriptSessionRecord | null>;
  deleteByIdForUser(id: string, userId: string): Promise<boolean>;
}

export interface CaptionFeedbackRepo {
  create(input: {
    userId: string;
    sessionId: string;
    rating: FeedbackRating;
    comment?: string | null;
  }): Promise<CaptionFeedbackRecord>;
}

export interface Repositories {
  users: UserRepo;
  transcriptSessions: TranscriptSessionRepo;
  captionFeedback: CaptionFeedbackRepo;
}
