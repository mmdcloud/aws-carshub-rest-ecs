output "global_accelerator_dns_name" {
  description = "DNS name of the Global Accelerator"
  value       = module.global_accelerator.dns_name
}

output "global_accelerator_hosted_zone_id" {
  description = "Hosted zone ID of the Global Accelerator"
  value       = module.global_accelerator.hosted_zone_id
}