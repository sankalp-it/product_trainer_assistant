
variable "aws_region" {
  default = "us-east-2"
}

variable "chroma_bucket_name" {
  default = "starckai-chroma-store"
}

variable "eks_cluster_azs" {
  default = ["us-east-2a", "us-east-2b"]
}


variable "eks_cluster_name" {
  default = "starckai_cluster"
}