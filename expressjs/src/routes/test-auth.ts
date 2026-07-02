import { getCurrentInvoke } from '@vendia/serverless-express';
import { Router } from 'express';
import { z } from 'zod';
import prisma from '../prisma';
import { asyncHandler } from '../utils/asyncHandler';
import { validate } from '../middleware/validate';

const router = Router();

const testAuthSchema = {
  response: z.object({
    message: z.string(),
    userId: z.string().optional(),
    user: z.any().optional(),
  }),
};

router.get(
  '/',
  validate(testAuthSchema),
  asyncHandler(async (_req, res) => {
    const { event } = getCurrentInvoke();
    const claims = event?.requestContext?.authorizer?.jwt?.claims || {};
    const userId = claims.sub;
    const email = claims.email;

    if (!email) {
      return res.status(401).json({ message: 'Unauthorized: No email claim found' });
    }

    if (!prisma) {
      return res.send({ message: `Hello, ${email}! (Database not connected)`, userId });
    }

    // Upsert user into database
    const user = await prisma.user.upsert({
      where: { email },
      update: { name: 'Updated User' },
      create: {
        email,
        name: 'New User',
      },
    });

    res.send({
      message: `Hello, ${user.email}! Welcome to your Aurora database.`,
      user,
    });
  }),
);

export default router;
