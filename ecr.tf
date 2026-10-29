# -----------------------------------------------------------------------------------------
# ECR Module
# -----------------------------------------------------------------------------------------

# Uncomment only if KMS is needed

# module "carshub_kms_ecr" {
#   source = "../../../modules/kms"
#   name = "carshub-kms-ecr-${var.env}-${var.region}"
#   description             = "KMS key for ECR encryption"
#   deletion_window_in_days = 30
#   enable_key_rotation     = true
# }

module "carshub_frontend_container_registry" {
  source               = "../../../modules/ecr"
  force_delete         = true
  scan_on_push         = false
  image_tag_mutability = "IMMUTABLE"
  name                 = "carshub-frontend-registry-${var.env}-${var.region}"
  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete untagged images older than 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  # Uncomment only if KMS is needed

  # encryption_type = "KMS"
  # kms_key         = module.carshub_kms_ecr.key_id

  tags = {
    Name        = "carshub-frontend-registry-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}

resource "null_resource" "build_and_push_frontend" {
  # Re-trigger build if any of these change
  triggers = {
    image_tag = "latest"
  }

  provisioner "local-exec" {
    command = "bash ${path.cwd}/../../../../../src/frontend/artifact_push.sh carshub-frontend-registry-${var.env}-${var.region} ${var.region} http://${module.carshub_backend_lb.dns_name} ${module.carshub_media_cloudfront_distribution.domain_name}"
  }

  depends_on = [
    module.carshub_frontend_container_registry,
  ]
}

module "carshub_backend_container_registry" {
  source               = "../../../modules/ecr"
  force_delete         = true
  scan_on_push         = false
  image_tag_mutability = "IMMUTABLE"
  name                 = "carshub-backend-registry-${var.env}-${var.region}"
  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete untagged images older than 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  # Uncomment only if KMS is needed

  # encryption_type = "KMS"
  # kms_key         = module.carshub_kms_ecr.key_id

  tags = {
    Name        = "carshub-backend-registry-${var.env}-${var.region}"
    Environment = "${var.env}"
    Project     = var.project
  }
}

resource "null_resource" "build_and_push_backend" {
  # Re-trigger build if any of these change
  triggers = {
    image_tag = "latest"
  }

  provisioner "local-exec" {
    command = "bash ${path.cwd}/../../../../../src/backend/api/artifact_push.sh carshub-backend-registry-${var.env}-${var.region} ${var.region}"
  }

  depends_on = [
    module.carshub_backend_container_registry,
  ]
}

resource "aws_ecr_replication_configuration" "carshub_ecr_replication" {
  replication_configuration {
    rule {
      destination {
        region      = "us-west-2"
        registry_id = data.aws_caller_identity.current.account_id
      }

      # Only replicate the carshub repos, not everything in the account
      repository_filter {
        filter      = "carshub-frontend-registry-${var.env}"
        filter_type = "PREFIX_MATCH"
      }

      repository_filter {
        filter      = "carshub-backend-registry-${var.env}"
        filter_type = "PREFIX_MATCH"
      }
    }
  }
}