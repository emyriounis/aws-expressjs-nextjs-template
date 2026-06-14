import { execSync } from 'child_process';
import path from 'path';

export const handler = async (event: any) => {
  console.log('Starting Prisma Migration...');

  try {
    // The lambda environment might not have HOME set correctly for some tools,
    // but npx prisma migrate deploy should work.

    // We need to set the DATABASE_URL environment variable for Prisma
    // This will be provided by Terraform from the secret manager/RDS output.
    if (!process.env.DATABASE_URL) {
      throw new Error('DATABASE_URL environment variable is missing!');
    }

    // Set the path to the prisma schema so the CLI knows where to find it.
    // In our zipped bundle, it should be at the root.
    const schemaPath = path.resolve(__dirname, 'prisma/schema.prisma');
    console.log(`Schema path: ${schemaPath}`);

    // Run the prisma migration command
    // We use the direct path to the Prisma CLI in the Lambda Layer (/opt)
    // to prevent npx from trying to download it from the internet (which fails in a private VPC).
    const prismaCli = '/opt/nodejs/node_modules/prisma/build/index.js';
    
    const maxRetries = 5;
    const retryDelayMs = 10000;
    let attempts = 0;
    let output = '';
    let success = false;

    while (attempts < maxRetries && !success) {
      try {
        attempts++;
        console.log(`Running migration attempt ${attempts} of ${maxRetries}...`);
        
        output = execSync(`node ${prismaCli} migrate deploy --schema=${schemaPath}`, {
          env: {
            ...process.env,
            // Ensure Prisma doesn't try to format output with colors which can mess up CloudWatch
            NO_COLOR: '1',
          },
          encoding: 'utf-8',
          stdio: 'pipe',
        });
        
        success = true;
      } catch (error: any) {
        console.error(`Attempt ${attempts} failed:`, error.message);
        if (error.stdout) console.error('STDOUT:', error.stdout);
        if (error.stderr) console.error('STDERR:', error.stderr);

        if (attempts < maxRetries) {
          console.log(`Waiting ${retryDelayMs / 1000} seconds before retrying...`);
          await new Promise((resolve) => setTimeout(resolve, retryDelayMs));
        } else {
          throw error;
        }
      }
    }

    console.log('Migration successful!');
    console.log(output);

    return {
      statusCode: 200,
      body: JSON.stringify({ message: 'Migration completed successfully', output }),
    };
  } catch (error: any) {
    console.error('Migration failed:', error.message);

    return {
      statusCode: 500,
      body: JSON.stringify({
        message: 'Migration failed',
        error: error.message,
      }),
    };
  }
};
