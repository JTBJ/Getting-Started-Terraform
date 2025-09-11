/*
This Terraform configuration sets up a basic web application on AWS using an EC2 instance running Nginx.
It includes the necessary networking components such as a VPC, subnet, internet gateway, and security groups.
AWS credentials are required to apply this configuration and can be set using environment variables or the AWS CLI.
*/

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  region = var.aws_region[0]
}

##################################################################################
# DATA
##################################################################################

data "aws_ssm_parameter" "amzn2_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

##################################################################################
# RESOURCES
##################################################################################

# NETWORKING #
resource "aws_vpc" "app" {
  cidr_block           = var.aws_vpc_cidr
  enable_dns_hostnames = true

  tags = local.common_tags
}

resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id

  tags = local.common_tags
}

resource "aws_subnet" "public_subnet1" {
  cidr_block              = var.aws_subnet_cidr
  vpc_id                  = aws_vpc.app.id
  map_public_ip_on_launch = true

  tags = local.common_tags
}

# ROUTING #
resource "aws_route_table" "app" {
  vpc_id = aws_vpc.app.id

  route {
    cidr_block = var.aws_route_cidr
    gateway_id = aws_internet_gateway.app.id
  }

  tags = local.common_tags
}

resource "aws_route_table_association" "app_subnet1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.app.id
}

# SECURITY GROUPS #
# Nginx security group 
resource "aws_security_group" "nginx_sg" {
  name   = "nginx_sg"
  vpc_id = aws_vpc.app.id

  # HTTP access from anywhere
  ingress {
    from_port   = var.aws_security_group_ingress_to_from_port
    to_port     = var.aws_security_group_ingress_to_from_port
    protocol    = var.aws_security_group_ingress_protocol
    cidr_blocks = [var.aws_route_cidr]
  }

  # outbound internet access
  egress {
    from_port   = var.aws_security_group_egress_port
    to_port     = var.aws_security_group_egress_port
    protocol    = var.aws_security_group_egress_port
    cidr_blocks = [var.aws_route_cidr]
  }

  tags = local.common_tags
}

# INSTANCES #
resource "aws_instance" "nginx1" {
  ami                         = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type               = var.instance_size["small"]
  subnet_id                   = aws_subnet.public_subnet1.id
  vpc_security_group_ids      = [aws_security_group.nginx_sg.id]
  user_data_replace_on_change = true

  tags = local.common_tags

  user_data =
    user_data = 
    <EOF
      #!/bin/bash
      yum update -y
      yum install -y httpd
      
      systemctl start httpd
      systemctl enable httpd
      
      cat << 'HTML' > /var/www/html/index.html
        <html>
        <head>
            <title>Taco Team Server</title>
        </head>
        <body style="background-color:#1F778D">
            <p style="text-align: center;">
                <span style="color:#FFFFFF;">
                    <span style="font-size:100px;">Welcome to the website! Have a 🌮</span>
                </span>
            </p>
        </body>
        </html>
      HTML
    EOF
}
