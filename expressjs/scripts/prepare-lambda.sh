#!/bin/bash

npm i
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
npm i --omit=dev

# Trigger the CLI to download the schema engines for the specified targets
npx prisma -v || true

npx prisma generate
mkdir nodejs
cp -r node_modules nodejs

# Remove macOS/darwin binaries to drastically reduce Lambda layer size (AWS uses Linux)
rm -rf nodejs/node_modules/@prisma/engines/*darwin*
rm -rf nodejs/node_modules/prisma/*darwin*
rm -rf nodejs/node_modules/.prisma/client/*darwin*

zip -rq layer.zip nodejs
rm -r nodejs
