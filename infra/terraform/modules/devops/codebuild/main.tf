
# # CodeBuild Configuration
# resource "aws_s3_bucket" "carshub_codebuild_cache_bucket" {
#   bucket        = "theplayer007-carshub-codebuild-cache-bucket"
#   force_destroy = true
# }

# data "aws_iam_policy_document" "codebuild_assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["codebuild.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }

# resource "aws_iam_role" "carshub_codebuild_iam_role" {
#   name               = "carshub-codebuild-iam-role"
#   assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
# }

# data "aws_iam_policy_document" "codebuild_cache_bucket_policy_document" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#     ]

#     resources = ["*"]
#   }

#   statement {
#     effect    = "Allow"
#     actions   = ["s3:*"]
#     resources = ["*"]
#   }

#   statement {
#     effect    = "Allow"
#     actions   = ["ecr:GetAuthorizationToken"]
#     resources = ["*"]
#   }

#   statement {
#     effect = "Allow"
#     actions = [
#       "ecr:BatchGetImage",
#       "ecr:BatchCheckLayerAvailability",
#       "ecr:CompleteLayerUpload",
#       "ecr:DescribeImages",
#       "ecr:DescribeRepositories",
#       "ecr:GetDownloadUrlForLayer",
#       "ecr:InitiateLayerUpload",
#       "ecr:ListImages",
#       "ecr:PutImage",
#       "ecr:UploadLayerPart"
#     ]
#     resources = [aws_ecr_repository.carshub.arn]
#   }
# }

# resource "aws_iam_role_policy" "carshub_codebuild_cache_bucket_policy" {
#   role   = aws_iam_role.carshub_codebuild_iam_role.name
#   policy = data.aws_iam_policy_document.codebuild_cache_bucket_policy_document.json
# }

# resource "aws_codebuild_project" "carshub_build" {
#   name          = "carshub-build"
#   description   = "carshub-build"
#   build_timeout = 60
#   service_role  = aws_iam_role.carshub_codebuild_iam_role.arn

#   artifacts {
#     type = "NO_ARTIFACTS"
#   }

#   cache {
#     type     = "S3"
#     location = aws_s3_bucket.carshub_codebuild_cache_bucket.bucket
#   }

#   environment {
#     compute_type                = "BUILD_GENERAL1_SMALL"
#     image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
#     type                        = "LINUX_CONTAINER"
#     image_pull_credentials_type = "CODEBUILD"
#     privileged_mode             = true

#     environment_variable {
#       name  = "ACCOUNT_ID"
#       value = data.aws_caller_identity.current.account_id
#     }

#     environment_variable {
#       name  = "REGION"
#       value = var.region
#     }

#     environment_variable {
#       name  = "REPO"
#       value = "carshub"
#     }
#   }

#   logs_config {
#     cloudwatch_logs {
#       group_name  = "carshub-log-group"
#       stream_name = "carshub-log-stream"
#     }

#     s3_logs {
#       status   = "ENABLED"
#       location = "${aws_s3_bucket.carshub_codebuild_cache_bucket.id}/build-log"
#     }
#   }

#   source {
#     type            = "GITHUB"
#     location        = "https://github.com/mmdcloud/carshub-rest-ecs.git"
#     git_clone_depth = 1

#     git_submodules_config {
#       fetch_submodules = true
#     }
#   }

#   source_version = "master"

#   tags = {
#     Name = "carshub-build"
#   }
# }


# CodeBuild Configuration
resource "aws_codebuild_project" "codebuild" {
  name          = var.name
  description   = var.description
  build_timeout = var.build_timeout
  service_role  = var.service_role

  artifacts {
    type = var.artifact_type
  }

  cache {
    type     = var.cache_type
    location = var.cache_location
  }

  environment {
    compute_type                = var.compute_type
    image                       = var.image
    type                        = var.type
    image_pull_credentials_type = var.image_pull_credentials_type
    privileged_mode             = var.privileged_mode
    dynamic "environment_variable"{
      for_each  = var.env_variables
      content = {
        name = environment_variable.value["name"]
        value = environment_variable.value["value"]
      }
    }    
  }

  logs_config {
    cloudwatch_logs {
      group_name  = var.cloudwatch_logs_group_name
      stream_name = var.cloudwatch_logs_stream_name
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.carshub_codebuild_cache_bucket.id}/build-log"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/mmdcloud/carshub-rest-ecs.git"
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = "master"

  tags = {
    Name = "carshub-build"
  }
}
