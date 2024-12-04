locals {
  vehicle_images_bucket_origin_id   = "carshub-vehicle-images-origin"
  vehicle_images_bucket_domain_name = "theplayer007-vehicle-images.s3.${var.region}.amazonaws.com"
}

# Origin Access Control for Cloudfront Distribution
resource "aws_cloudfront_origin_access_control" "carshub-vehicle-images-s3-oac" {
  name                              = "carshub-vehicle-images-s3-oac"
  description                       = "carshub-vehicle-images-s3-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Configuring Cloudfront CDN for media file delivery
resource "aws_cloudfront_distribution" "carshub_vehicle_images_cloudfront_distribution" {
  enabled = true
  origin {
    origin_id                = local.vehicle_images_bucket_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.carshub-vehicle-images-s3-oac.id
    domain_name              = local.vehicle_images_bucket_domain_name
    connection_attempts      = 3
    connection_timeout       = 10
  }
  default_cache_behavior {
    compress         = true
    smooth_streaming = false
    target_origin_id = local.vehicle_images_bucket_origin_id
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  price_class     = "PriceClass_200"
  is_ipv6_enabled = false
  tags = {
    Name = "carshub"
  }
}

# MediaConvert Destination Bucket to Cloudfront Access Policy
resource "aws_s3_bucket_policy" "mediaconvert_destination_s3_bucket_policy" {
  bucket = aws_s3_bucket.vehicle-images.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "PolicyForCloudFrontPrivateContent",
    "Statement" : [
      {
        "Sid" : "AllowCloudFrontServicePrincipal",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com"
        },
        "Action" : "s3:GetObject",
        "Resource" : "${aws_s3_bucket.vehicle-images.arn}/*",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn" : "${aws_cloudfront_distribution.carshub_vehicle_images_cloudfront_distribution.arn}"
          }
        }
      }
    ]
  })
}
