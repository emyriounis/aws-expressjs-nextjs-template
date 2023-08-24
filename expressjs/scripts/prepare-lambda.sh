#!/bin/bash

npm i
rm -r build/
npm run build

cd build/
rm -r ../source.zip
zip -r ../source.zip *
cd ..

rm -rf node_modules/
rm -r layer.zip
npm i --only=prod
mkdir nodejs
cp -r node_modules nodejs
zip -r layer.zip nodejs
rm -r nodejs
