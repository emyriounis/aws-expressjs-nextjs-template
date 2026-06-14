#!/bin/bash

npm ci
rm -rf build/
npm run build

# Copy prisma schema and migrations into the build directory so it's packaged
cp -r prisma build/

cd build/
rm -f ../source.zip
zip -rq ../source.zip *
cd ..

rm -rf node_modules/
rm -f layer.zip

# Force Prisma CLI to download the schema engine for AWS Lambda (rhel) as well as native
export PRISMA_CLI_BINARY_TARGETS=darwin-arm64,rhel-openssl-3.0.x
npm ci --omit=dev

# Trigger the CLI to download the schema engines for the specified targets
npx prisma -v || true

npx prisma generate
mkdir nodejs
cp -r node_modules nodejs

# Keep ONLY the rhel-openssl-3.0.x query engine in .prisma/client, delete all other query engine files (like darwin, debian, etc.)
find nodejs/node_modules/.prisma/client -name "libquery_engine-*" ! -name "libquery_engine-rhel-openssl-3.0.x*" -delete

# Keep ONLY the rhel-openssl-3.0.x schema engine in @prisma/engines, delete all other engines
find nodejs/node_modules/@prisma/engines -name "libquery_engine-*" -delete
find nodejs/node_modules/@prisma/engines -name "schema-engine-*" ! -name "schema-engine-rhel-openssl-3.0.x*" -delete

# Clean up all query/schema engines from prisma CLI package
rm -rf nodejs/node_modules/prisma/libquery_engine*
rm -rf nodejs/node_modules/prisma/schema-engine*

# Remove peerOptional typescript package to save 23MB
rm -rf nodejs/node_modules/typescript

# Remove all source maps (.map files) to save ~17MB zipped
find nodejs/node_modules -name "*.map" -delete

# Remove TypeScript declaration files (.d.ts / .d.mts) to save additional megabytes
find nodejs/node_modules -name "*.d.ts" -delete
find nodejs/node_modules -name "*.d.mts" -delete

# Clean up non-postgresql engine/compiler files from @prisma/client, prisma/prisma-client, and prisma/build
find nodejs/node_modules/@prisma/client/runtime -type f \( -name "*cockroachdb*" -o -name "*mysql*" -o -name "*sqlite*" -o -name "*sqlserver*" \) -delete
find nodejs/node_modules/prisma/prisma-client/runtime -type f \( -name "*cockroachdb*" -o -name "*mysql*" -o -name "*sqlite*" -o -name "*sqlserver*" \) -delete
find nodejs/node_modules/prisma/build -type f \( -name "*cockroachdb*" -o -name "*mysql*" -o -name "*sqlite*" -o -name "*sqlserver*" \) -delete

# Remove Prisma Studio public assets from the CLI package
rm -rf nodejs/node_modules/prisma/build/public

zip -rq layer.zip nodejs
rm -r nodejs
