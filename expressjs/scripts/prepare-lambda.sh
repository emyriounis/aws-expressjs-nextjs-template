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

# Remove native query engine binaries to save size (the Data API adapter uses WASM/JS engine in production)
rm -rf nodejs/node_modules/@prisma/engines/libquery_engine*
rm -rf nodejs/node_modules/prisma/libquery_engine*
rm -rf nodejs/node_modules/.prisma/client/libquery_engine*

# Remove peerOptional typescript package to save 23MB
rm -rf nodejs/node_modules/typescript

# Remove non-postgresql WASM files to save ~39MB
rm -rf nodejs/node_modules/@prisma/client/runtime/query_engine_bg.cockroachdb*
rm -rf nodejs/node_modules/@prisma/client/runtime/query_engine_bg.mysql*
rm -rf nodejs/node_modules/@prisma/client/runtime/query_engine_bg.sqlite*
rm -rf nodejs/node_modules/@prisma/client/runtime/query_engine_bg.sqlserver*

rm -rf nodejs/node_modules/@prisma/client/runtime/query_compiler_bg.cockroachdb*
rm -rf nodejs/node_modules/@prisma/client/runtime/query_compiler_bg.mysql*
rm -rf nodejs/node_modules/@prisma/client/runtime/query_compiler_bg.sqlite*
rm -rf nodejs/node_modules/@prisma/client/runtime/query_compiler_bg.sqlserver*

zip -rq layer.zip nodejs
rm -r nodejs
