#!/bin/bash
set -e

# Lambda code is now inline in template.yaml (CloudFormation)
# This script triggers a stack update to deploy any Lambda changes

REGION="ca-central-1"
STACK_NAME="foomist"

echo "Updating Lambda via CloudFormation stack update..."

aws cloudformation update-stack \
  --stack-name "$STACK_NAME" \
  --template-body file://template.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --region "$REGION" \
  --use-previous-template \
  2>&1 || echo "No updates needed or update in progress"

echo ""
echo "To force Lambda code update, modify template.yaml and run ./deploy.sh"
