
# Signing Profile
resource "aws_signer_signing_profile" "signing_profile" {
  platform_id = var.platform_id
  signature_validity_period {
    value = var.signature_validity_value
    type  = var.signature_validity_type
  }
}

resource "aws_lambda_code_signing_config" "signing_config" {
  allowed_publishers {
    signing_profile_version_arns = [aws_signer_signing_profile.signing_profile.version_arn]
  }
  policies {
    untrusted_artifact_on_deployment = var.untrusted_artifact_on_deployment
  }
}

resource "aws_signer_signing_job" "build_signing_job" {
  profile_name = aws_signer_signing_profile.signing_profile.name
  source {
    s3 {
      bucket  = var.s3_bucket_source
      key     = var.s3_bucket_key
      version = var.s3_bucket_version
    }
  }
  destination {
    s3 {
      bucket = var.s3_bucket_destination
    }
  }
  ignore_signing_job_failure = var.ignore_signing_job_failure
}
