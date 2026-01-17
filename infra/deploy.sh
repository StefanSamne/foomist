#!/bin/bash
set -e

STACK_NAME="foomist"
REGION="ca-central-1"
DOMAIN="foom.ist"

# Check required params
if [ -z "$CERTIFICATE_ARN" ]; then
  echo "Error: CERTIFICATE_ARN environment variable required"
  echo "Create cert in us-east-1 first, then:"
  echo "  export CERTIFICATE_ARN=arn:aws:acm:us-east-1:xxx:certificate/xxx"
  exit 1
fi

if [ -z "$HOSTED_ZONE_ID" ]; then
  echo "Error: HOSTED_ZONE_ID environment variable required"
  echo "Find it with: aws route53 list-hosted-zones"
  echo "  export HOSTED_ZONE_ID=Z0123456789ABCDEFGHIJ"
  exit 1
fi

echo "Deploying CloudFormation stack: $STACK_NAME"

aws cloudformation deploy \
  --template-file template.yaml \
  --stack-name "$STACK_NAME" \
  --region "$REGION" \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    DomainName="$DOMAIN" \
    CertificateArn="$CERTIFICATE_ARN" \
    HostedZoneId="$HOSTED_ZONE_ID" \
  --tags Project=foomist

echo ""
echo "Stack deployed. Getting outputs..."

aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --region "$REGION" \
  --query 'Stacks[0].Outputs' \
  --output table

echo ""
echo "Next steps:"
echo "1. Upload site:  ./upload-site.sh"
echo "2. Deploy Lambda: ./deploy-lambda.sh"
