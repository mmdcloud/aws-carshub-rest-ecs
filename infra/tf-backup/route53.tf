# resource "aws_route53_zone" "primary" {
#   name = "madmaxcloud.online"
# }

# data "aws_route53_zone" "primary" {
#   name         = "madmaxcloud.online"
#   private_zone = false
#   depends_on = [ aws_route53_zone.primary ]
# }

# resource "aws_route53_record" "aws_route53_records" {
#   for_each = {
#     for dvo in aws_acm_certificate.carshub_cert.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = data.aws_route53_zone.primary.zone_id
# }

# resource "aws_route53_record" "frontend_lb" {
#   zone_id         = aws_route53_zone.primary.zone_id
#   name            = "website.madmaxcloud.online"
#   allow_overwrite = true
#   type            = "CNAME"
#   ttl             = 300
#   records         = [aws_lb.lb.dns_name]
# }

# resource "aws_route53_record" "backend_lb" {
#   zone_id         = aws_route53_zone.primary.zone_id
#   name            = "api.madmaxcloud.online"
#   allow_overwrite = true
#   type            = "CNAME"
#   ttl             = 300
#   records         = [aws_lb.frontend-lb.dns_name]
# }