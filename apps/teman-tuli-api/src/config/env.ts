import 'dotenv/config';
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().default(3000),
  DATABASE_URL: z.string().optional(),
  JWT_SECRET: z.string().min(16).optional()
});

const parsedEnv = envSchema.parse(process.env);

if (parsedEnv.NODE_ENV !== 'test') {
  if (!parsedEnv.DATABASE_URL) {
    throw new Error('DATABASE_URL is required for development and production environments');
  }

  if (!parsedEnv.JWT_SECRET) {
    throw new Error('JWT_SECRET is required for development and production environments');
  }
}

export const env = {
  ...parsedEnv,
  DATABASE_URL: parsedEnv.DATABASE_URL ?? 'postgresql://postgres:postgres@localhost:5432/teman_tuli_test',
  JWT_SECRET: parsedEnv.JWT_SECRET ?? 'test-only-jwt-secret'
};
