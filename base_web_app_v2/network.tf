
#################################################################################
# Data
#################################################################################

# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
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

# INTERNET GATEWAY
resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id

  tags = local.common_tags
}

# SUBNETS
resource "aws_subnet" "public_subnets" {
  count                   = var.vpc_public_subnet_count
  cidr_block              = var.aws_public_subnet_cidr[count.index]
  vpc_id                  = aws_vpc.app.id
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

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

# ASSOCIATIONS 
resource "aws_route_table_association" "app_subnets" {
  count          = var.vpc_public_subnet_count
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.app.id
}

# SECURITY GROUPS # 
resource "aws_security_group" "nginx_sg" {
  name   = "nginx_sg"
  vpc_id = aws_vpc.app.id

  # HTTP access from anywhere
  ingress {
    from_port = var.aws_security_group_ingress_to_from_port
    to_port   = var.aws_security_group_ingress_to_from_port
    protocol  = var.aws_security_group_ingress_protocol
    # cidr_blocks = [var.aws_vpc_cidr]
    security_groups = [aws_security_group.alb_sg.id]
  }

  # outbound internet access
  egress {
    from_port   = var.aws_security_group_egress_port
    to_port     = var.aws_security_group_egress_port
    protocol    = var.aws_security_group_egress_protocol
    cidr_blocks = [var.aws_route_cidr]
  }

  tags = local.common_tags
}

resource "aws_security_group" "alb_sg" {
  name   = "nginx_alb_sg"
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
    protocol    = var.aws_security_group_egress_protocol
    cidr_blocks = [var.aws_route_cidr]
  }

  tags = local.common_tags
}
