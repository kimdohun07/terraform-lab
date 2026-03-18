output "auto_web1_public_ip" {
  value = aws_instance.auto_web1.public_ip
}

output "auto_web2_public_ip" {
  value = aws_instance.auto_web2.public_ip
}

output "auto_alb_dns_name" {
  value = aws_lb.auto_web_alb.dns_name
}