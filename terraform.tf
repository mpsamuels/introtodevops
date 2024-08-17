# AWS Provider
provider "aws" {
  region = "eu-west-2"
}

# EC2 Instance type variable with default value
variable "instance_type" {
  default = "t2.micro"
}

# Data call to retrieve AZ names of current region
data "aws_availability_zones" "available" {
  state = "available"
}

# Create key pair for SSH access to instance
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}

# AWS VPC
resource "aws_vpc" "intro-to-devops-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "intro-to-devops-vpc"
  }
}

# AWS Subnets
resource "aws_subnet" "intro_to_devops_subnet1" {
  cidr_block        = "10.0.0.0/24"
  vpc_id            = aws_vpc.intro-to-devops-vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Purpose : "intro-to-devops"
    Name : "Subnet1"
  }
}

resource "aws_subnet" "intro_to_devops_subnet2" {
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.intro-to-devops-vpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Purpose : "intro-to-devops"
    Name : "Subnet2"
  }
}

resource "aws_subnet" "intro_to_devops_subnet3" {
  cidr_block        = "10.0.2.0/24"
  vpc_id            = aws_vpc.intro-to-devops-vpc.id
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Purpose : "intro-to-devops"
    Name : "Subnet3"
  }
}

# AWS Security Group with port 80 open inbound and all traffic allowed out
resource "aws_security_group" "intro_to_devops_sg" {
  name        = "intro_to_devops_sg"
  description = "Security group"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# AWS EC2 Instance with user data to install apache and create basic index.html
resource "aws_instance" "intro_to_devops_ec2" {
  ami             = "ami-05ea2888c91c97ca7"
  instance_type   = var.instance_type
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.intro_to_devops_sg.name]
  user_data       = <<EOF
#!/bin/bash
dnf update -y
dnf install -y httpd.x86_64
systemctl start httpd.service
bash -c 'echo \"Intro To DevOps!\" > /var/www/html/index.html'
systemctl enable httpd.service
EOF
}

# Output public IP address
output "intro_to_devops_ec2_ip" {
  value = aws_instance.intro_to_devops_ec2.public_ip
}