# S3 Bucket for storing vehicle images
resource "aws_s3_bucket" "vehicle-images" {
  bucket        = "theplayer007-vehicle-images"
  force_destroy = true
  tags = {
    Name = "theplayer007-vehicle-images"
  }
}

# Creating folders
resource "aws_s3_object" "vehicle-images-folder" {
  bucket = aws_s3_bucket.vehicle-images.id
  key    = "images/"
}

resource "aws_s3_object" "vehicle-documents-folder" {
  bucket = aws_s3_bucket.vehicle-images.id
  key    = "documents/"
}

resource "aws_s3_bucket_cors_configuration" "carshub-vehicle-images-cors" {
  bucket = aws_s3_bucket.vehicle-images.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket" "vehicle-images-code" {
  bucket        = "theplayer007-vehicle-images-code"
  force_destroy = true
  tags = {
    Name = "theplayer007-vehicle-images-code"
  }
}

resource "aws_s3_bucket_versioning" "vehicle-images-code-versioning" {
  bucket = aws_s3_bucket.vehicle-images-code.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "vehicle-images-code-signed" {
  bucket        = "theplayer007-vehicle-images-code-signed"
  force_destroy = true
  tags = { Name = "theplayer007-vehicle-images-code-signed"
  }
}

resource "aws_s3_object" "vehicle-images-code-object" {
  bucket = aws_s3_bucket.vehicle-images-code.id
  key    = "lambda.zip"
  source = "./files/lambda.zip"
}
