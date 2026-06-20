import request from 'supertest';
import app from '../../src/app';
import { getCurrentInvoke } from '@vendia/serverless-express';
import prisma from '../../src/prisma';

jest.mock('@vendia/serverless-express');

beforeEach(async () => {
  if (prisma) {
    await prisma.user.deleteMany();
  }
});

afterAll(async () => {
  if (prisma) {
    await prisma.$disconnect();
  }
});

describe('GET /test-auth', () => {
  test('gets cognito claims', async () => {
    jest.mocked(getCurrentInvoke).mockReturnValueOnce({
      event: {
        requestContext: {
          authorizer: {
            jwt: {
              claims: {
                sub: 'user-id',
                email: 'email',
              },
            },
          },
        },
      },
    });
    const res = await request(app).get('/test-auth');

    expect(res.status).toBe(200);

    expect(res.body).toStrictEqual({
      message: 'Hello, email! Welcome to your Aurora database.',
      user: {
        id: expect.any(String),
        email: 'email',
        name: 'New User',
        createdAt: expect.any(String),
      },
    });
  });
});
