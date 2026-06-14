import { PrismaClient } from '@prisma/client';

let prisma: PrismaClient | null = null;

// Debug log to inspect environment state on Lambda cold starts
console.log('Prisma initialization started. Env state:', {
  NODE_ENV: process.env.NODE_ENV,
  DATABASE_URL: process.env.DATABASE_URL ? 'present' : 'missing',
});

try {
  prisma = new PrismaClient({
    datasourceUrl: process.env.DATABASE_URL,
  });
  console.log('Prisma Client successfully initialized.');
} catch (e) {
  console.error('Error during Prisma initialization:', e);
  console.warn('Prisma initialization failed.');
}

export default prisma;
