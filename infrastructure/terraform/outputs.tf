
output "chroma_bucket_name" {
  value = aws_s3_bucket.chroma_data.bucket
}

output "eks_cluster_name" {
  value = aws_eks_cluster.starckai_cluster.name
}

output "eks_kubeconfig" {
  value = aws_eks_cluster.starckai_cluster.endpoint
}
