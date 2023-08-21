import { Router } from 'express'
import heartbeatRouter from './heartbeat'

const router = Router()

router.use('/heartbeat', heartbeatRouter)

export default router
