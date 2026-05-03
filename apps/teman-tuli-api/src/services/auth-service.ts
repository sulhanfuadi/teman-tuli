import type { Repositories } from '../repositories/interfaces.js';
import { hashPassword, verifyPassword } from '../utils/password.js';

export class AuthService {
  constructor(private readonly repos: Repositories) {}

  async register(input: { name: string; email: string; password: string; goal?: string }) {
    const existing = await this.repos.users.findByEmail(input.email.toLowerCase());
    if (existing) {
      throw new Error('EMAIL_ALREADY_USED');
    }

    const passwordHash = await hashPassword(input.password);
    const user = await this.repos.users.create({
      name: input.name,
      email: input.email.toLowerCase(),
      passwordHash,
      goal: input.goal
    });

    return {
      id: user.id,
      name: user.name,
      email: user.email,
      goal: user.goal
    };
  }

  async login(input: { email: string; password: string }) {
    const user = await this.repos.users.findByEmail(input.email.toLowerCase());
    if (!user) {
      throw new Error('INVALID_CREDENTIALS');
    }

    const validPassword = await verifyPassword(input.password, user.passwordHash);
    if (!validPassword) {
      throw new Error('INVALID_CREDENTIALS');
    }

    return {
      id: user.id,
      name: user.name,
      email: user.email,
      goal: user.goal
    };
  }
}
