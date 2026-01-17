#!/bin/bash
set -e

REGION="ca-central-1"
STACK_NAME="foomist"

# Get bucket name and CloudFront distribution ID from stack outputs
BUCKET=$(aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --region "$REGION" \
  --query 'Stacks[0].Outputs[?OutputKey==`SiteBucketName`].OutputValue' \
  --output text)

DISTRIBUTION_ID=$(aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --region "$REGION" \
  --query 'Stacks[0].Outputs[?OutputKey==`CloudFrontDistributionId`].OutputValue' \
  --output text)

echo "Uploading to S3 bucket: $BUCKET"

aws s3 sync ../. "s3://$BUCKET" \
  --exclude ".git/*" \
  --exclude "lambda/*" \
  --exclude "infra/*" \
  --exclude "CLAUDE.md" \
  --exclude ".github/*" \
  --delete \
  --region "$REGION"

echo "Invalidating CloudFront cache..."

aws cloudfront create-invalidation \
  --distribution-id "$DISTRIBUTION_ID" \
  --paths "/*" \
  --query 'Invalidation.Id' \
  --output text

echo ""
echo "Site uploaded! Visit: https://foom.ist"
