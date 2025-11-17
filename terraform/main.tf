terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "chatbot-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "chatbot-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "chatbot-igw"
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "chatbot-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group (SSH:22, Streamlit:8501)
resource "aws_security_group" "chatbot_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict to your IP in prod
  }
  ingress {
    from_port   = 8501
    to_port     = 8501
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
    Name = "chatbot-sg"
  }
}

# EC2 Instance (Ubuntu 22.04, user_data for basics)
resource "aws_instance" "chatbot" {
  ami           = "ami-087d1c9a513324697"  # Ubuntu 22.04 LTS ap-south-1 (free tier)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.chatbot_sg.id]
  key_name      = var.key_name  # Optional: Add your EC2 key pair name for SSH
  user_data     = <<-EOF
                  #!/bin/bash
                  apt-get update
                  apt-get install -y python3-pip python3-venv git
                  EOF
  tags = {
    Name = "chatbot-ec2"
  }
}

# Output EC2 public IP (for Ansible)
output "ec2_public_ip" {
  value = aws_instance.chatbot.public_ip
}