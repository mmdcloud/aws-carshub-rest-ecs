resource "aws_acm_certificate" "carshub_cert" {
  domain_name       = "madmaxcloud.online"  
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "carshub_cert_validate" {
  certificate_arn         = aws_acm_certificate.carshub_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.aws_route53_records : record.fqdn]
}