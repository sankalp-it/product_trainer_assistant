#!/bin/bash
echo "Starting infrastructure and syncing embeddings from S3..."
terraform -chdir=../terraform apply -auto-approve
BUCKET=$(terraform -chdir=../terraform output -raw chroma_bucket_name)
aws s3 sync s3://$BUCKET/chroma_store ./backend/chroma_store
