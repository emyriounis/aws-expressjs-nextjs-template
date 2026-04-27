import { getCurrentInvoke } from '@vendia/serverless-express'
import { Router } from 'express'

const router = Router()

router.get('/', (_req, res, next) => {
  try {
    const { event } = getCurrentInvoke()
    const claims = event.requestContext.authorizer.jwt.claims
    const userId = claims.sub
    const email = claims.email

    res.send({ message: `Hello, ${email}!`, userId })
  } catch (error) {
    return next(error)
  }
})

export default router
