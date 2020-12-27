#!/bin/sh
mkdir -p dist/nodejs
cp package.json dist/nodejs
cd dist/nodejs
npm install
cd ..
zip -r /tmp/momentJSLambdaLayer.zip nodejs
cd ..
rm -rf dist