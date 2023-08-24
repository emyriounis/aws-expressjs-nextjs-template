import { Router } from 'express'

const router = Router()

router.get('/', async (_req, res, next) => {
  try {
    return res.json({ data: new Date() })
  } catch (error) {
    return next(error)
  }
})

router.post('/', async (req, res, next) => {
  try {
    return res.json({ data: req.body })
  } catch (error) {
    return next(error)
  }
})

export default router
