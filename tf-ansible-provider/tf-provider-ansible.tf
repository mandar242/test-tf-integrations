terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    ansible = {
      version = "~> 1.2.0"
      source  = "ansible/ansible"
    }
  }
}

# Configure AWS provider =========================
provider "aws" {
    access_key = "xxxxxxxxxxxx"
    secret_key = "xxxxxxxxxxxx"
    region = "us-west-1"
}

# GET AMI =================================================
data "aws_ami" "instance_ami_al2" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  owners = ["amazon"]  # Amazon's AWS account ID
}

# NETWORKING SETUP ========================================
# Create VPC
resource "aws_vpc" "mk-provider-test" {
  cidr_block           = "172.16.0.0/22"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    "Name" = "mk-provider-test-vpc"
  }
}

# Create Subnet
resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.mk-provider-test.id
  cidr_block        = "172.16.0.0/24"
  availability_zone = "us-west-1a"
  depends_on = [aws_vpc.mk-provider-test]
  tags = {
    "Name" = "mk-provider-test-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "mk-provider-test_gw" {
    vpc_id = aws_vpc.mk-provider-test.id
    depends_on = [ aws_vpc.mk-provider-test ]
    tags = {
      "Name" = "mk-provider-test-igw"
  }
}

# Create Security Group
resource "aws_security_group" "security" {
  name = "allow-all"
  vpc_id = aws_vpc.mk-provider-test.id
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow all outbound"
  }
 ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [ aws_vpc.mk-provider-test ]
  tags = {
    "Name" = "mk-provider-test-sg"
  }
}

# Create Route Table
resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.mk-provider-test.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mk-provider-test_gw.id
  }
  depends_on = [aws_vpc.mk-provider-test]
}

# Create Route Table Association
resource "aws_route_table_association" "route-table-association" {
  subnet_id = aws_subnet.subnet.id
  route_table_id = aws_route_table.route-table.id
  depends_on = [aws_subnet.subnet]
}

# Create EC2 Instance ===========================================
resource "aws_instance" "mk-provider-test_ec2" {
  ami                         = data.aws_ami.instance_ami_al2.id
  instance_type               = "t2.micro"
  key_name        = "mandkulk-us-west-1-vms"
  associate_public_ip_address = true
  subnet_id = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.security.id]
  tags = {
    "Name" = "mk-provider-test-instance"
  }
}