output "aws_instance_public_dns_hostname" {
  value       = "http://${aws_instance.nginx1.public_dns}"
  description = "Public DNS hostname of web server"
}
