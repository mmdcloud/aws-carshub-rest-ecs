output "carshub_backend_load_balancer_dns" {
  value = module.carshub_backend_lb.lb_dns_name
}

output "carshub_frontend_load_balancer_dns" {
  value = module.carshub_frontend_lb.lb_dns_name
}