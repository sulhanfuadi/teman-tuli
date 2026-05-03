import { describe, expect, it } from 'vitest';
import { AuthService } from '../../src/services/auth-service.js';
import { createInMemoryRepositories } from '../support/in-memory-repos.js';

describe('AuthService', () => {
  it('registers and logs in a user', async () => {
    const repos = createInMemoryRepositories();
    const service = new AuthService(repos);

    const registered = await service.register({
      name: 'Sulhan',
      email: 'sulhan@example.com',
      password: 'password123'
    });

    expect(registered.email).toBe('sulhan@example.com');

    const loggedIn = await service.login({
      email: 'sulhan@example.com',
      password: 'password123'
    });

    expect(loggedIn.id).toBe(registered.id);
  });
});
