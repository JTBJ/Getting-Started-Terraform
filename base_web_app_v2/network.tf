
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
module "app" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.0"

  cidr = var.aws_vpc_cidr

  azs            = slice(data.aws_availability_zones.available.names, 0, var.vpc_public_subnet_count)
  public_subnets = [for s in range(var.vpc_public_subnet_count) : cidrsubnet(var.aws_vpc_cidr, 8, s)]

  enable_nat_gateway      = false
  enable_vpn_gateway      = false
  enable_dns_hostnames    = true
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-vpc" })
}

# SECURITY GROUPS # 
resource "aws_security_group" "nginx_sg" {
  name   = "${local.naming_prefix}-nginx_sg"
  vpc_id = module.app.vpc_id

  # HTTP access from anywhere
  ingress {
    from_port       = var.aws_security_group_ingress_to_from_port
    to_port         = var.aws_security_group_ingress_to_from_port
    protocol        = var.aws_security_group_ingress_protocol
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
  name   = "${local.naming_prefix}-alb_sg"
  vpc_id = module.app.vpc_id

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
