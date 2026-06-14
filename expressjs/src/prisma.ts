import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import { createPgClient } from 'data-api-client/compat/pg';

let prisma: PrismaClient | null = null;

// Debug log to inspect environment state on Lambda cold starts
console.log('Prisma initialization started. Env state:', {
  NODE_ENV: process.env.NODE_ENV,
  AURORA_CLUSTER_ARN: process.env.AURORA_CLUSTER_ARN ? 'present' : 'missing',
  SECRET_ARN: process.env.SECRET_ARN ? 'present' : 'missing',
  DATABASE_NAME: process.env.DATABASE_NAME ? 'present' : 'missing',
  DATABASE_URL: process.env.DATABASE_URL ? 'present' : 'missing',
});

try {
  if (
    process.env.NODE_ENV === 'prod' &&
    process.env.AURORA_CLUSTER_ARN &&
    process.env.SECRET_ARN &&
    process.env.DATABASE_NAME
  ) {
    console.log('Attempting to initialize Prisma with RDS Data API driver adapter...');
    const rdsClient = createPgClient({
      resourceArn: process.env.AURORA_CLUSTER_ARN,
      secretArn: process.env.SECRET_ARN,
      database: process.env.DATABASE_NAME,
    });

    const adapter = new PrismaPg(rdsClient);
    prisma = new PrismaClient({ adapter });
    console.log('Prisma Client with RDS Data API adapter successfully initialized.');
  } else {
    console.log('Initialization fallback: Using standard PrismaClient (TCP)...');
    prisma = new PrismaClient();
  }
} catch (e) {
  console.error('Error during Prisma initialization:', e);
  console.warn('Prisma initialization skipped / failed.');
}

export default prisma;
