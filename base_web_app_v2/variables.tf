variable "aws_region" {
  type        = list(string)
  description = "AWS region to use for resources"
  default     = ["us-east-1", "us-east-2", "us-west-1", "us-west-2"]
}

variable "aws_vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC in AWS"
  default     = "10.0.0.0/16"
}

variable "aws_subnet_cidr" {
  type        = string
  description = "CIDR block for the subnet in AWS"
  default     = "10.0.0.0/24"
}

variable "aws_route_cidr" {
  type        = string
  description = "CDIR block for the route table in AWS"
  default     = "0.0.0.0/0"
}

variable "aws_security_group_ingress_to_from_port" {
  type        = number
  description = "Ingress to and from port for the security group in AWS"
  default     = 80
}

variable "aws_security_group_ingress_protocol" {
  type        = string
  description = "Protocol used for inbound traffic to the instance in AWS"
  default     = "tcp"
}

variable "aws_security_group_egress_port" {
  type        = number
  description = "Egress port for the security group in AWS"
  default     = 0
}

variable "aws_security_group_egress_protocol" {
  type        = string
  description = "Protocol used for outbound traffic from the instance in AWS"
  default     = "-1"
}

variable "instance_size" {
  type        = map(string)
  description = "Instance size to use in AWS"
  default = {
    small  = "t3.micro"
    medium = "t4.large"
    large  = "t4.xlarge"
  }
}

variable "company" {
  type        = string
  description = "Company name for resource tagging"
  default     = "Globomantics"
}

variable "project" {
  type        = string
  description = "Project name for resource tagging"
}

variable "billing_code" {
  type        = string
  description = "Billing code for resource tagging"
}

