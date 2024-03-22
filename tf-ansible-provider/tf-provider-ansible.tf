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
resource "aws_instance" "mk_provider_test_ec2" {
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

# ANSIBLE PROVIDER TESTS ============================================
# Add created ec2 instance to ansible inventory
resource "ansible_host" "my_ec2" {
  name   = aws_instance.mk_provider_test_ec2.public_dns
  groups = ["playbook-group-1"] # add ec2 instance to this group
  variables = {
    ansible_user                 = "ec2-user",
    ansible_ssh_private_key_file = "~/path/to/mandkulk-us-west-1-vms.pem",
    ansible_python_interpreter   = "/usr/bin/python3",
  }
}

# RUN Playbook on EC2 instance - simple-playbook.yml
resource "ansible_playbook" "example_playbook_run_1" {
  ansible_playbook_binary = "ansible-playbook" # this parameter is optional, default is "ansible-playbook"
  playbook                = "simple-playbook.yml"

  # Inventory configuration
  name   = ansible_host.my_ec2.name    # name of the host to use for inventory configuration
  groups = ["playbook-group-1"] # list of groups to add our host to

  # Limit this playbook to run only on the host named ansible_host.my_ec2.name
  limit = [
    ansible_host.my_ec2.name
  ]
  check_mode = false
  diff_mode  = false
  var_files = ["var-file.yml"]

  # Connection configuration and other vars
  extra_vars = {
    # ansible_hostname   = docker_container.julia_the_first.name
    # ansible_connection = "docker"
    ansible_user                 = "ec2-user",
    ansible_ssh_private_key_file = "~/path/to/mandkulk-us-west-1-vms.pem",
    ansible_python_interpreter   = "/usr/bin/python3",
  }
  replayable = true
  verbosity  = 3 # set the verbosity level of the debug output for this playbook
}

# RUN Playbook on EC2 instance - updated-simple-playbook.yml
resource "ansible_playbook" "example_playbook_run_2" {
  ansible_playbook_binary = "ansible-playbook" # this parameter is optional, default is "ansible-playbook"
  playbook                = "updated-simple-playbook.yml"

  # Inventory configuration
  name   = ansible_host.my_ec2.name    # name of the host to use for inventory configuration
  groups = ["playbook-group-1"] # list of groups to add our host to

  # Limit this playbook to run only on the host named "julia-the-first"
  limit = [
    ansible_host.my_ec2.name
  ]
  check_mode = false
  diff_mode  = false
  var_files = ["var-file.yml"]

  # Connection configuration and other vars
  extra_vars = {
    # ansible_hostname   = docker_container.julia_the_first.name
    # ansible_connection = "docker"
    ansible_user                 = "ec2-user",
    ansible_ssh_private_key_file = "~/path/to/mandkulk-us-west-1-vms.pem",
    ansible_python_interpreter   = "/usr/bin/python3",
  }
  replayable = true
  verbosity  = 3 # set the verbosity level of the debug output for this playbook
}