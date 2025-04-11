# Provider configuration for AWS

# Create VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Create subnets (public)
resource "aws_subnet" "eks_subnet_a" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "eks_subnet_b" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true
}

# Create Security Group for the EKS worker nodes
resource "aws_security_group" "eks_security_group" {
  name        = "eks-security-group"
  description = "Allow communication to EKS worker nodes"
  vpc_id      = aws_vpc.eks_vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create IAM Role for EKS
resource "aws_iam_role" "eks_role" {
  name = "eksRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })
}

# Attach the required policies to the IAM role for EKS
resource "aws_iam_role_policy_attachment" "eks_policy_attach" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# IAM Role for the EKS worker nodes
resource "aws_iam_role" "eks_worker_role" {
  name = "eksWorkerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })
}

# Attach the necessary policies to the worker IAM role
resource "aws_iam_role_policy_attachment" "worker_policy_attach" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "ec2_policy_attach" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "vpc_policy_attach" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

# EKS Cluster creation
resource "aws_eks_cluster" "eks_cluster" {
  name     = "my-eks-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids         = [aws_subnet.eks_subnet_a.id, aws_subnet.eks_subnet_b.id]
    security_group_ids = [aws_security_group.eks_security_group.id]
  }
}

# Create the EKS worker node group (EC2 Auto Scaling Group)
resource "aws_launch_configuration" "eks_launch_config" {
  name          = "eks-launch-config"
  image_id      = "ami-0c55b159cbfafe1f0" # Update to the correct ECS optimized AMI ID for your region
  instance_type = "t2.micro"              # You can change the instance type as per your requirement

  security_groups = [aws_security_group.eks_security_group.id]

  iam_instance_profile = aws_iam_instance_profile.eks_worker_profile.name

  user_data = <<-EOF
              #!/bin/bash
              echo "EKS_CLUSTER=my-eks-cluster" > /etc/eks/eks.config
              /etc/init.d/docker start
              /etc/init.d/ecs start
              EOF
}

# Create an IAM instance profile for the worker nodes
resource "aws_iam_instance_profile" "eks_worker_profile" {
  name = "eksWorkerProfile"
  role = aws_iam_role.eks_worker_role.name
}

# Create Auto Scaling Group for worker nodes
resource "aws_autoscaling_group" "eks_asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = [aws_subnet.eks_subnet_a.id, aws_subnet.eks_subnet_b.id]
  launch_configuration = aws_launch_configuration.eks_launch_config.id

  tag {
    key                 = "Name"
    value               = "EKSWorkerNode"
    propagate_at_launch = true
  }
}

# Output the cluster endpoint
output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

# Output the cluster name
output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}
