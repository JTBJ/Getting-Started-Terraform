# aws_elb_service_account
data "aws_elb_service_account" "root" {}

# aws_lb
resource "aws_lb" "nginx" {
  name               = "${local.naming_prefix}-globo-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for subnet in module.app.public_subnets : subnet]

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.app.bucket
    prefix  = "alb-logs"
    enabled = true
  }

  depends_on = [aws_s3_bucket_policy.web_bucket]

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-globo-web-alb" })
}

# aws_target_group
resource "aws_lb_target_group" "nginx" {
  name     = "${local.naming_prefix}-alb-tg"
  port     = var.aws_security_group_ingress_to_from_port
  protocol = "HTTP"
  vpc_id   = module.app.vpc_id

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-globo-web-alb-tg" })
}

# aws_lb_listener
resource "aws_lb_listener" "nginx" {
  load_balancer_arn = aws_lb.nginx.arn
  port              = var.aws_security_group_ingress_to_from_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx.arn
  }

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-nginx_lb_listener" })
}

# aws_lb_target_group_attachment
resource "aws_lb_target_group_attachment" "nginx" {
  for_each = {
    for index, instance in aws_instance.nginx : index => instance
  }

  target_group_arn = aws_lb_target_group.nginx.arn
  target_id        = each.value.id
  port             = var.aws_security_group_ingress_to_from_port
}

# resource "aws_lb_target_group_attachment" "nginx" {
#   count = var.instance_count
#   target_group_arn = aws_lb_target_group.nginx.arn
#   target_id        = aws_instance.nginx[count.index].id
#   port             = var.aws_security_group_ingress_to_from_port
# }
