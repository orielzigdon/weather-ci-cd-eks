provider "aws" {
  region = "eu-north-1"
}

# Security Group for EKS
resource "aws_security_group" "eks" {
  vpc_id = "vpc-083fa706fc11c9402"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-security-group"
  }
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement : [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "eks.amazonaws.com" },
    }]
  })

  tags = {
    Name = "eks-cluster-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = "eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids         = ["subnet-0ceacd74bce478876", "subnet-0cd79f8af91fddb8a"]
    security_group_ids = [aws_security_group.eks.id]
  }

  tags = {
    Name = "eks-cluster"
  }
}

# IAM Role for Worker Nodes
resource "aws_iam_role" "eks_node_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement : [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
    }]
  })

  tags = {
    Name = "eks-node-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_node_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
  ])

  role       = aws_iam_role.eks_node_role.name
  policy_arn = each.value
}

# Node Group for EKS Cluster
resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "eks-cluster-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = ["subnet-0ceacd74bce478876", "subnet-0cd79f8af91fddb8a"]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.micro"] #t3.small for argo & helm
  ami_type       = "AL2_x86_64"

  tags = {
    Name = "eks-cluster-node-group"
  }
}
