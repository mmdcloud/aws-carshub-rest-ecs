# CodeBuild Configuration
resource "aws_s3_bucket" "codebuild_cache_bucket" {
  bucket        = "theplayer007-codebuild-cache-bucket"
  force_destroy = true
}

data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codebuild_iam_role" {
  name               = "codebuild-iam-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
}

data "aws_iam_policy_document" "codebuild_cache_bucket_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = [
	"ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:DescribeImages",
        "ecr:DescribeRepositories",
        "ecr:GetDownloadUrlForLayer",
        "ecr:InitiateLayerUpload",
        "ecr:ListImages",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
    ]
    resources = [aws_ecr_repository.nodeapp.arn]
  }
}

resource "aws_iam_role_policy" "codebuild_cache_bucket_policy" {
  role   = aws_iam_role.codebuild_iam_role.name
  policy = data.aws_iam_policy_document.codebuild_cache_bucket_policy_document.json
}

resource "aws_codebuild_project" "nodeapp_build" {
  name          = "nodeapp-build"
  description   = "nodeapp-build"
  build_timeout = 60
  service_role  = aws_iam_role.codebuild_iam_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.codebuild_cache_bucket.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }

    environment_variable {
      name  = "REGION"
      value = var.region
    }

    environment_variable {
      name  = "REPO"
      value = "nodeapp"
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "nodeapp-log-group"
      stream_name = "nodeapp-log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.codebuild_cache_bucket.id}/build-log"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/mmdcloud/aws-ecr-ecs.git"
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = "master"

  tags = {
    Environment = "NodeApp-Build"
  }
}

# CodePipeline Configuration
resource "aws_codestarconnections_connection" "codepipeline_codestart_connection" {
  name          = "codestar-connection"
  provider_type = "GitHub"
}

resource "aws_codepipeline" "nodeapp_pipeline" {
  name     = "nodeapp-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      input_artifacts  = []

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.codepipeline_codestart_connection.arn
        FullRepositoryId = "mmdcloud/aws-ecr-ecs"
        BranchName       = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.nodeapp_build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ClusterName = aws_ecs_cluster.nodeapp-cluster.name
        ServiceName = aws_ecs_service.nodeapp-service.name
        FileName    = "imagedefinitions.json"
      }
    }
  }
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket        = "theplayer007-codepipeline-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "codepipeline_bucket_pab" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "codepipeline_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json
}

resource "aws_iam_role_policy_attachment" "codepipeline_ecs_full_access" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.codepipeline_bucket.arn,
      "${aws_s3_bucket.codepipeline_bucket.arn}/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "codedeploy:GetDeploymentConfig",
    ]

    resources = [
      "arn:aws:codedeploy:us-east-1:${data.aws_caller_identity.current.account_id}:deploymentconfig:CodeDeployDefault.OneAtATime"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection"]
    resources = [aws_codestarconnections_connection.codepipeline_codestart_connection.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = ["*"]
  }
 
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "codepipeline-policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}