import { Router } from 'express'
import heartbeatRouter from './heartbeat'
import testAuthRouter from './test-auth'

const router = Router()

router.use('/heartbeat', heartbeatRouter)
router.use('/test-auth', testAuthRouter)

export default router
