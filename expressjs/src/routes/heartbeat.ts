import { Router } from 'express';
import { asyncHandler } from '../utils/asyncHandler';

const router = Router();

router.get(
  '/',
  asyncHandler(async (_req, res) => {
    return res.json({ data: new Date() });
  }),
);

router.post(
  '/',
  asyncHandler(async (req, res) => {
    return res.json({ data: req.body });
  }),
);

export default router;
