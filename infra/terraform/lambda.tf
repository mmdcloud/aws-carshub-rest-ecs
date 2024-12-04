locals {
  runtime = "python3.12"
  handler = "lambda.lambda_handler"
}

# Lambda Function Role
resource "aws_iam_role" "carshub-lambda-function-role" {
  name               = "carshub-lambda-function-role"
  assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Principal": {
                  "Service": "lambda.amazonaws.com"
                },
                "Effect": "Allow",
                "Sid": ""
            }
        ]
    }
    EOF
}

# Lambda Function Policy
resource "aws_iam_policy" "carshub-lambda-function-policy" {
  name        = "carshub-lambda-function-policy"
  description = "AWS IAM Policy for managing aws lambda role"
  policy      = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": [
                  "logs:CreateLogGroup",
                  "logs:CreateLogStream",
                  "logs:PutLogEvents"
                ],
                "Resource": "arn:aws:logs:*:*:*",
                "Effect": "Allow"
            },
            {
              "Effect": "Allow",
              "Action": "secretsmanager:GetSecretValue",
              "Resource": "*"
            },
            {
                "Action": "s3:*",
                "Effect": "Allow",
                "Resource": "arn:aws:s3:::theplayer007-vehicle-images/*"
            }
        ]
    }
    EOF
}

# Lambda Function Role-Policy Attachment
resource "aws_iam_role_policy_attachment" "shiftme-lambda-function-policy-attachment" {
  role       = aws_iam_role.carshub-lambda-function-role.name
  policy_arn = aws_iam_policy.carshub-lambda-function-policy.arn
}


# Lambda Function
resource "aws_lambda_function" "carshub-update-vehicle-image" {
  #filename      = "./files/lambda.zip"
  function_name = "carshub-update-vehicle-image"
  role          = aws_iam_role.carshub-lambda-function-role.arn
  handler       = local.handler
  runtime       = local.runtime
  s3_bucket     = aws_s3_bucket.vehicle-images-code.bucket
  s3_key        = "lambda.zip"
  environment {
    variables = {
      SECRET_NAME = aws_secretsmanager_secret.rds_creds.name
      DB_HOST     = tostring(split(":", aws_db_instance.carshub-db.endpoint)[0])
      DB_NAME     = var.db_name
      REGION      = var.region
    }
  }
  layers                  = [aws_lambda_layer_version.python_layer.arn]
  code_signing_config_arn = aws_lambda_code_signing_config.carshub_signing_config.arn
}

# Granting invocation permission to s3 for lambda
resource "aws_lambda_permission" "vehicle-images-function-s3-invocation-permission" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.carshub-update-vehicle-image.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.vehicle-images.arn
}

# Specifying bucket and function configuration for the trigger
resource "aws_s3_bucket_notification" "vehicle-images-bucket-notification" {
  bucket = aws_s3_bucket.vehicle-images.bucket
  lambda_function {
    lambda_function_arn = aws_lambda_function.carshub-update-vehicle-image.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.vehicle-images-function-s3-invocation-permission]
}

# Lambda Layer for storing dependencies
resource "aws_lambda_layer_version" "python_layer" {
  filename            = "./files/python.zip"
  layer_name          = "python"
  compatible_runtimes = ["python3.12"]
}

# Signing Profile
resource "aws_signer_signing_profile" "carshub_signing_profile" {
  # name_prefix = "carshub_signing_profile"
  platform_id = "AWSLambda-SHA384-ECDSA"
  signature_validity_period {
    value = 5
    type  = "YEARS"
  }
}

resource "aws_lambda_code_signing_config" "carshub_signing_config" {
  allowed_publishers {
    signing_profile_version_arns = [aws_signer_signing_profile.carshub_signing_profile.version_arn]
  }
  policies {
    untrusted_artifact_on_deployment = "Warn"
  }
}

resource "aws_signer_signing_job" "build_signing_job" {
  profile_name = aws_signer_signing_profile.carshub_signing_profile.name

  source {
    s3 {
      bucket  = aws_s3_bucket.vehicle-images-code.bucket
      key     = "lambda.zip"
      version = aws_s3_object.vehicle-images-code-object.version_id
    }
  }

  destination {
    s3 {
      bucket = aws_s3_bucket.vehicle-images-code-signed.bucket
    }
  }

  ignore_signing_job_failure = true
  depends_on                 = [aws_lambda_function.carshub-update-vehicle-image]
}
