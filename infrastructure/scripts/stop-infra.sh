#!/bin/bash
echo "Stopping infrastructure and syncing embeddings to S3..."
BUCKET=$(terraform -chdir=../terraform output -raw chroma_bucket_name)
aws s3 sync ./backend/chroma_store s3://$BUCKET/chroma_store
terraform -chdir=../terraform destroy -auto-approve
