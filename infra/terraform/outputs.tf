output "load_balancer_ip" {
  value = aws_lb.lb.dns_name
}

output "frontend_load_balancer_ip" {
  value = aws_lb.frontend-lb.dns_name
}