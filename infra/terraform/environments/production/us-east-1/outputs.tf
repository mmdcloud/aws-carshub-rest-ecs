output "carshub_backend_load_balancer_dns" {
  value = module.carshub_backend_lb.dns_name
}

output "carshub_frontend_load_balancer_dns" {
  value = module.carshub_frontend_lb.dns_name
}