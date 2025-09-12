# aws_lb
resource "aws_lb" "nginx" {
  name               = "globo-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]

  enable_deletion_protection = false

  tags = local.common_tags
}

# aws_target_group
resource "aws_lb_target_group" "nginx" {
  name     = "globo-web-alb-tg"
  port     = var.aws_security_group_ingress_to_from_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.app.id
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
}

# aws_lb_target_group_attachment
resource "aws_lb_target_group_attachment" "nginx" {
  for_each = {
    for k, v in [aws_instance.nginx1, aws_instance.nginx2] :
    k => v
  }

  target_group_arn = aws_lb_target_group.nginx.arn
  target_id        = each.value.id
  port             = var.aws_security_group_ingress_to_from_port
}
