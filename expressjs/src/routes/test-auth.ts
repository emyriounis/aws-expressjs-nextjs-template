import { getCurrentInvoke } from '@vendia/serverless-express';
import { Router } from 'express';
import prisma from '../prisma';

const router = Router();

router.get('/', async (_req, res, next) => {
  try {
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
      update: {}, // Just fetch if exists
      create: {
        email,
        name: 'New User',
      },
    });

    res.send({
      message: `Hello, ${user.email}! Welcome to your Aurora database.`,
      user,
    });
  } catch (error) {
    console.error('Error in test-auth:', error);
    return next(error);
  }
});

export default router;
