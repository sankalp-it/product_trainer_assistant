
provider "aws" {
  region = var.aws_region
}
provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "aws_eip" "nat_eip" {
  #vpc = true
  tags = {
    Name = "starckai_nat_eip"
  }
}

resource "aws_vpc" "starckai_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "starckai_vpc"
  }
}

resource "aws_subnet" "starckai_public_subnet_a" {
  vpc_id            = aws_vpc.starckai_vpc.id
  cidr_block        = "10.0.1.0/24"
  # availability_zone = data.aws_availability_zones.available.names[0]
  availability_zone = var.eks_cluster_azs[0]
  # availability_zone = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "starckai_public_subnet_a"
    "kubernetes.io/cluster/starckai_cluster" = "owned"
    "kubernetes.io/role/elb"                 = "1"
  }
}

resource "aws_subnet" "starckai_public_subnet_b" {
  vpc_id            = aws_vpc.starckai_vpc.id
  cidr_block        = "10.0.2.0/24"
  # availability_zone = data.aws_availability_zones.available.names[0]
  availability_zone = var.eks_cluster_azs[1]
  # availability_zone = "us-east-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "starckai_public_subnet_b"
    "kubernetes.io/cluster/starckai_cluster" = "owned"
    "kubernetes.io/role/elb"                 = "1"
  }
}

# Private Subnet A
resource "aws_subnet" "starckai_private_subnet_a" {
  vpc_id                  = aws_vpc.starckai_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = var.eks_cluster_azs[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "starckai_private_subnet_a"
    "kubernetes.io/cluster/starckai_cluster" = "owned"
    "kubernetes.io/role/internal-elb"         = "1"
  }
}

# Private Subnet B
resource "aws_subnet" "starckai_private_subnet_b" {
  vpc_id                  = aws_vpc.starckai_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = var.eks_cluster_azs[1]
  map_public_ip_on_launch = false
  tags = {
    Name = "starckai_private_subnet_b"
    "kubernetes.io/cluster/starckai_cluster" = "owned"
    "kubernetes.io/role/internal-elb"         = "1"
  }
}

resource "aws_internet_gateway" "starckai_igw" {
  vpc_id = aws_vpc.starckai_vpc.id

  tags = {
    Name = "starckai_igw"
  }
}
resource "aws_nat_gateway" "starckai_nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.starckai_public_subnet_a.id
  tags = {
    Name = "starckai_nat_gw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.starckai_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.starckai_igw.id
  }
  tags = {
    Name = "starckai_public_rt"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.starckai_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.starckai_nat_gw.id
  }
  tags = {
    Name = "starckai_private_rt"
  }
}

# Public subnet associations
resource "aws_route_table_association" "public_rt_assoc_a" {
  subnet_id      = aws_subnet.starckai_public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_assoc_b" {
  subnet_id      = aws_subnet.starckai_public_subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

# Private subnet associations
resource "aws_route_table_association" "private_rt_assoc_a" {
  subnet_id      = aws_subnet.starckai_private_subnet_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_assoc_b" {
  subnet_id      = aws_subnet.starckai_private_subnet_b.id
  route_table_id = aws_route_table.private_rt.id
}

data "aws_availability_zones" "available" {}

resource "aws_iam_role" "eks_node_role" {
  name = "starckai_eks_node_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = [
          "ec2.amazonaws.com",
          "eks.amazonaws.com"
        ]
      }
      Effect = "Allow"
      Sid    = ""
    }]
  })

  tags = {
    Name = "starckai_eks_node_role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_worker_attach" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "eks_cni_attach" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
resource "aws_iam_role_policy_attachment" "eks_registry_attach" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
resource "aws_iam_role_policy_attachment" "eks_ecr_attach" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}
resource "aws_iam_role_policy_attachment" "eks_autoscaler_attach" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
}
resource "aws_iam_role_policy_attachment" "eks_cloudwatch_attach" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}
resource "aws_iam_role_policy_attachment" "eks_vpc_attach" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_eks_cluster" "starckai_cluster" {
  name     = "starckai_cluster"
  role_arn = aws_iam_role.eks_node_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.starckai_public_subnet_a.id, aws_subnet.starckai_public_subnet_b.id,
                  aws_subnet.starckai_private_subnet_a.id, aws_subnet.starckai_private_subnet_b.id]
    endpoint_private_access = true # For private access to the cluster
    endpoint_public_access  = true # For public access to the cluster
    #To be done later
    #Set endpoint_public_access = false
    #Set up a bastion host or SSM Session Manager for private access
    # Or restrict public access to a CIDR allowlist like your office IP
  }

  depends_on = [aws_iam_role_policy_attachment.eks_worker_attach]
}

resource "aws_eks_node_group" "on_demand" {
  cluster_name    = aws_eks_cluster.starckai_cluster.name
  node_group_name = "starckai-eks-on-demand-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [aws_subnet.starckai_public_subnet_a.id, aws_subnet.starckai_public_subnet_b.id]
  instance_types  = ["t3a.small"]
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
}

resource "aws_eks_node_group" "spot" {
  cluster_name    = aws_eks_cluster.starckai_cluster.name
  node_group_name = "starckai-eks-spot-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [aws_subnet.starckai_private_subnet_a.id, aws_subnet.starckai_private_subnet_b.id]
  instance_types  = ["t3a.medium"]
  capacity_type   = "SPOT"
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
}

resource "aws_s3_bucket" "chroma_data" {
  bucket = var.chroma_bucket_name
  force_destroy = true
  tags = {
    Name = "starckai-eks-chroma-store"
    Environment = "dev"
  }
}

data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.eks_cluster_name
}

data "tls_certificate" "oidc_thumbprint" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc_thumbprint.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "ebs_assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.this.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}



resource "kubernetes_storage_class" "gp3_default" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "ebs.csi.aws.com"

  reclaim_policy = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type = "gp3"
  }
}

   # Add EBS_CSI resource
resource "aws_eks_addon" "ebs_csi" {
  cluster_name  = aws_eks_cluster.starckai_cluster.name
  addon_name    = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_driver_role.arn

  tags = {
    Name = "ebs-csi-driver"
  }
}
  # Create IAM Role for CSI Driver
resource "aws_iam_role" "ebs_csi_driver_role" {
  name = "AmazonEKS_EBS_CSI_DriverRole"

  assume_role_policy = data.aws_iam_policy_document.ebs_assume_role.json
}

# data "aws_iam_policy_document" "ebs_assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["eks.amazonaws.com", "ec2.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }

resource "aws_iam_role_policy_attachment" "ebs_attach" {
  role       = aws_iam_role.ebs_csi_driver_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}