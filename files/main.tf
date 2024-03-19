terraform {
  backend "s3" {
    bucket = "mandkulk-tf-test-bucket"
    key = "terraform/my.tfstate"
    region = "us-west-1"
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    google = {
      source = "hashicorp/google"
    }
  }
}


##AWS INSTANCE ==============================================================================

provider "aws" {
    access_key = "xxxxxxxxxxxx"
    secret_key = "xxxxxxxxxxxx"
    region = "us-west-1"
}

variable "cloud_terraform_vpc_name" {
  type = string
  default = "mandkulk-test-vpc"
}

variable "cidr_block" {
  type = string
  default = "172.168.0.0/26"
}

resource "aws_vpc" "test_vpc" {
  cidr_block = var.cidr_block
  tags       = {
    Name                           = var.cloud_terraform_vpc_name
    cloud_terraform_integration    = "true"
    Owner = "mandkulk"
    Persistent = "False"
  }
}

resource "aws_subnet" "test_subnet" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "172.168.0.0/26"
  availability_zone = "us-west-1a"

  tags = {
    Name = "mandkulk-tf-example"
    Owner = "mandkulk"
  }
}

resource "aws_network_interface" "test_network_interface" {
  subnet_id   = aws_subnet.test_subnet.id
  tags = {
    Name = "mandkulk-primary_network_interface"
    Owner = "mandkulk"
  }
}

resource "aws_instance" "example_server" {
  ami           = "ami-0353faff0d421c70e"
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.test_network_interface.id
    device_index         = 0
  }

  tags = {
    Name = "mandkulk-tf-test-instance"
  }
}


## GOOGLE VM GCP INSTANCE ==============================================================================
provider "google" {
  project     = "project-gcp-001-test"
  region      = "us-east1"
  zone        = "us-east1-b"
  credentials = "/paht/to/credentials.json"
}

resource "google_compute_instance" "mandkulk" {
  provider = google
  name = "mandkulk"
  machine_type = "e2-micro"
  network_interface {
    network = "default"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-focal-v20220712"
    }
  }
  # Some changes require full VM restarts
  # consider disabling this flag in production
  #   depending on your needs
  allow_stopping_for_update = true
  labels = {
    owner = "mandkulk"
    environment = "cloud-content-test"
  }
}
