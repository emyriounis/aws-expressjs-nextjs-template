import express, { NextFunction, Request, Response } from 'express'
import 'dotenv/config'
import cors from 'cors'
import routes from './routes/routes'

const app = express()

app.use(cors())
app.use(express.json())

app.use('/', routes)
app.use('*', (_req, res) => res.sendStatus(404))

app.use((err: any, _req: Request, res: Response, _next: NextFunction) => {
  console.error(`Error handler caught: `, err)
  return res.sendStatus(500)
})

export default app
