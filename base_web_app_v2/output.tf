# aws_lb.nginx
output "aws_alb_public_dns_hostname" {
  value       = "http://${aws_lb.nginx.dns_name}"
  description = "Public DNS hostname of web server"
}
