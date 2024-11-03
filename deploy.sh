#!/bin/sh

terraform -chdir=src/terraform init
terraform -chdir=src/terraform apply

BUCKET_NAME=$(terraform -chdir=src/terraform output -raw s3_bucket_id)
echo Uploading content to $BUCKET_NAME...
aws s3 sync ./src/website/ s3://$BUCKET_NAME/ --delete

CLOUDFRONT_ID=$(terraform -chdir=src/terraform output -raw cloudfront_distribution_id)
echo Invalidating CloudFront Cache for ID: $CLOUDFRONT_ID
INVALIDATION_OUTPUT=$(aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_ID --paths "/*")
INVALIDATION_ID=$(echo $INVALIDATION_OUTPUT | jq -r '.Invalidation.Id')

echo Waiting for invalidation with ID: $INVALIDATION_ID
aws cloudfront wait invalidation-completed --distribution-id $CLOUDFRONT_ID --id $INVALIDATION_ID