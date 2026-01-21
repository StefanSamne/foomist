#!/bin/bash
set -e

# Lambda code is now inline in template.yaml (CloudFormation)
# This script triggers a stack update to deploy any Lambda changes

REGION="ca-central-1"
STACK_NAME="foomist"

echo "Updating Lambda via CloudFormation stack update..."

# Get current parameter values from the stack
CURRENT_PARAMS=$(aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --region "$REGION" \
  --query 'Stacks[0].Parameters' \
  --output json)

# Build parameter overrides to use previous values
PARAM_OVERRIDES=""
for param in $(echo "$CURRENT_PARAMS" | jq -r '.[].ParameterKey'); do
  PARAM_OVERRIDES="$PARAM_OVERRIDES ParameterKey=$param,UsePreviousValue=true"
done

aws cloudformation update-stack \
  --stack-name "$STACK_NAME" \
  --template-body file://template.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --region "$REGION" \
  --parameters $PARAM_OVERRIDES \
  2>&1 || echo "No updates needed or update in progress"

echo ""
echo "Waiting for stack update to complete..."
aws cloudformation wait stack-update-complete \
  --stack-name "$STACK_NAME" \
  --region "$REGION" \
  2>&1 || echo "Stack update completed or nothing to update"

echo ""
echo "Lambda deployed!"
