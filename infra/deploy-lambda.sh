#!/bin/bash
set -e

REGION="ca-central-1"
FUNCTION_NAME="foomist-create-issue"
LAMBDA_DIR="../lambda/create-issue"

echo "Installing dependencies..."
cd "$LAMBDA_DIR"
npm install --production

echo "Creating deployment package..."
zip -r function.zip index.js package.json node_modules

echo "Deploying Lambda function..."
aws lambda update-function-code \
  --function-name "$FUNCTION_NAME" \
  --zip-file fileb://function.zip \
  --region "$REGION" \
  --query 'LastModified' \
  --output text

echo "Cleaning up..."
rm function.zip

echo ""
echo "Lambda deployed!"
