# -----------------------------------------------------------------------------------------
# Cloudfront distribution
# -----------------------------------------------------------------------------------------
module "carshub_media_cloudfront_distribution" {
  source                                = "../../../modules/cloudfront"
  distribution_name                     = "carshub-media-cdn-${var.env}-${var.region}"
  oac_name                              = "carshub-media-cdn-oac-${var.env}-${var.region}"
  oac_description                       = "carshub-media-cdn-oac-${var.env}-${var.region}"
  oac_origin_access_control_origin_type = "s3"
  oac_signing_behavior                  = "always"
  oac_signing_protocol                  = "sigv4"
  enabled                               = true
  origin = [
    {
      origin_id           = "carshub-media-bucket-${var.env}-${var.region}"
      domain_name         = "carshub-media-bucket-${var.env}.s3.${var.region}.amazonaws.com"
      connection_attempts = 3
      connection_timeout  = 10
    },
    {
      origin_id           = "carshub-media-bucket-${var.env}-us-west-2"
      domain_name         = "carshub-media-bucket-${var.env}.s3.us-west-2.amazonaws.com"
      connection_attempts = 3
      connection_timeout  = 10
    }
  ]
  origin_groups = [
    {
      origin_id    = "carshub-media-origin-group-${var.env}"
      status_codes = [500, 502, 503, 504, 403, 404]
      members = [
        "carshub-media-bucket-${var.env}-${var.region}",
        "carshub-media-bucket-${var.env}-us-west-2"
      ]
    }
  ]
  compress                       = true
  smooth_streaming               = false
  target_origin_id               = "carshub-media-origin-group-${var.env}"
  allowed_methods                = ["GET", "HEAD"]
  cached_methods                 = ["GET", "HEAD"]
  viewer_protocol_policy         = "redirect-to-https"
  min_ttl                        = 0
  default_ttl                    = 86400
  max_ttl                        = 31536000
  price_class                    = "PriceClass_200"
  forward_cookies                = "all"
  cloudfront_default_certificate = true
  geo_restriction_type           = "none"
  query_string                   = true
  tags = {
    Name        = "carshub-media-cdn-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}