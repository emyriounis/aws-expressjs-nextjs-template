import request from 'supertest'
import app from '../../src/app'

describe('GET /heartbeat', () => {
  test('sends back the request body', async () => {
    const dateRegex = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z$/
    const res = await request(app).get('/heartbeat')

    expect(res.status).toBe(200)
    expect(res.body.data).toMatch(dateRegex)
  })
})

describe('POST /heartbeat', () => {
  test('sends back the request body', async () => {
    const data = { message: 'Test data' }

    const res = await request(app).post('/heartbeat').send(data)

    expect(res.status).toBe(200)
    expect(res.body).toStrictEqual({ data })
  })
})
