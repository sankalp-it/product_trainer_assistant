# AI Summary Assistant

**Current Version:** v1.14.5
**Changelog:**
- Added full EKS provisioning via Terraform (Cluster + VPC + Subnets + IAM)
- Includes 1× t3a.small on-demand, 1× t3a.medium Spot
- Updated Terraform outputs and Helm bucket integration
- S3 bucket creation and dynamic reference preserved

## Deployment Options

### Manual (Recommended for Initial Testing)
```
cd infrastructure/terraform
terraform apply

cd ../helm
helm upgrade --install api ./api --set chromaBucketName=...
```

### GitOps with Argo CD
- Install Argo CD using `argocd.tf` (coming next)
- Apply app manifests from `infrastructure/argocd/*.yaml`
