# AI Summary Assistant - Changelog

## v1.14.6
- Added GitHub Actions CI/CD: build + manual deploy workflows
- Added Argo CD support: Helm-based Application manifests for API, worker, frontend
- Argo CD installation instructions scaffolded for EKS
- Manual deployment workflow preserved and documented

## v1.14.5
- Full Terraform-based EKS infrastructure (VPC, IAM, nodegroups, etc.)
- S3 persistence for embeddings, dynamic sync

## v1.14.4
- Terraform S3 bucket creation + dynamic usage in Helm/scripts

## v1.14.3
- Version alignment update

## v1.14.2
- S3-based ChromaDB sync with scripts + initContainers

## v1.14.1
- Semantic search with HuggingFace, embedding scores
