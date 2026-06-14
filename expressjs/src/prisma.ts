import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import { createPgClient } from 'data-api-client/compat/pg';

let prisma: PrismaClient | null = null;

try {
  if (
    process.env.NODE_ENV === 'prod' &&
    process.env.AURORA_CLUSTER_ARN &&
    process.env.SECRET_ARN &&
    process.env.DATABASE_NAME
  ) {
    const rdsClient = createPgClient({
      resourceArn: process.env.AURORA_CLUSTER_ARN,
      secretArn: process.env.SECRET_ARN,
      database: process.env.DATABASE_NAME,
    });

    const adapter = new PrismaPg(rdsClient);
    prisma = new PrismaClient({ adapter });
  } else {
    prisma = new PrismaClient();
  }
} catch (e) {
  console.warn('Prisma initialization skipped (likely local dev without env vars)');
}

export default prisma;
