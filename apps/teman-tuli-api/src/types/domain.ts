export type FeedbackRating = 'POOR' | 'OKAY' | 'GOOD' | 'EXCELLENT';

export interface UserRecord {
  id: string;
  name: string;
  email: string;
  passwordHash: string;
  goal: string | null;
}

export interface TranscriptSegmentRecord {
  id: string;
  sessionId: string;
  text: string;
  startMs: number;
  endMs: number | null;
}

export interface TranscriptSessionRecord {
  id: string;
  userId: string;
  title: string;
  className: string | null;
  languageCode: string;
  fullText: string;
  notes: string | null;
  startedAt: Date;
  endedAt: Date;
  createdAt: Date;
  updatedAt: Date;
  segments?: TranscriptSegmentRecord[];
}

export interface CaptionFeedbackRecord {
  id: string;
  userId: string;
  sessionId: string;
  rating: FeedbackRating;
  comment: string | null;
  createdAt: Date;
}
