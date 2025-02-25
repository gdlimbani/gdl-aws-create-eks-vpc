provider "aws" {
  region = "${var.region}"  # Specify your region
}

# Data source to fetch the existing IAM role
data "aws_iam_role" "existing_role" {
  name = "${var.role_name}"  # Replace with your existing IAM role name
}

# Create a VPC
resource "aws_vpc" "example" {
  cidr_block = "${var.vpc_cidr_block}"
  
  tags = {
    Name = "${var.vpc_name}"
    "Created By": "${var.resource_created_by}"
    "Environment": "Development"
  }
}

# Create public subnets
resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "gdl-public-subnet-1"
    "Created By": "${var.resource_created_by}"
    "Environment": "Development"
  }
}

resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "gdl-public-subnet-2"
    "Created By": "${var.resource_created_by}"
    "Environment": "Development"
  }
}

# Create a public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "gdl-public-route-table"
    "Created By": "${var.resource_created_by}"
    "Environment": "Development"
  }
}

# Associate subnets with the route table
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

# Create an internet gateway
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "gdl-internet-gateway"
    "Created By": "${var.resource_created_by}"
    "Environment": "Development"
  }
}

# Create a route to the internet gateway
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.example.id
}

# EKS Cluster definition
resource "aws_eks_cluster" "example" {
  name     = "${var.cluster_name}"
  version = "${var.cluster_version}"
  role_arn = data.aws_iam_role.existing_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.public1.id, aws_subnet.public2.id]
  }
  tags = {
    "Created By": "${var.resource_created_by}"
    "Environment": "Development"
  }
}

# EKS Node Group definition
resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.example.name
  node_group_name = "${var.eks_node_group}"
  node_role_arn   = data.aws_iam_role.existing_role.arn
  subnet_ids      = [aws_subnet.public1.id, aws_subnet.public2.id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["${var.eks_node_instance_type}"]
  ami_type = "AL2_x86_64"  # Use the AL2 Amazon Linux 2 AMI (this is for EKS version 1.24)

  tags = {
    "Created By": "${var.resource_created_by}"
    "Environment": "Development"
  }
}
