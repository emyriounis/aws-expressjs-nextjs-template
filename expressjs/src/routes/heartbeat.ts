import { Router } from 'express';
import { z } from 'zod';
import { asyncHandler } from '../utils/asyncHandler';
import { validate } from '../middleware/validate';

const router = Router();

const getSchema = {
  response: z.object({
    data: z.date(),
  }),
};

router.get(
  '/',
  validate(getSchema),
  asyncHandler(async (_req, res) => {
    return res.json({ data: new Date() });
  }),
);

const postSchema = {
  body: z.looseObject({}),
  response: z.object({
    data: z.looseObject({}),
  }),
};

router.post(
  '/',
  validate(postSchema),
  asyncHandler(async (req, res) => {
    return res.json({ data: req.body });
  }),
);

export default router;
