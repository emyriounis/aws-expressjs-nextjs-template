import request from 'supertest'
import app from '../../src/app'
import { getCurrentInvoke } from '@vendia/serverless-express'

jest.mock('@vendia/serverless-express')

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
    })
    const res = await request(app).get('/test-auth')

    expect(res.status).toBe(200)
    expect(res.body).toStrictEqual({
      message: 'Hello, email!',
      userId: 'user-id',
    })
  })
})
