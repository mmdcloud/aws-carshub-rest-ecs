# CodePipeline Configuration
resource "aws_codestarconnections_connection" "codepipeline_codestar_connection" {
  name          = "codestar-connection"
  provider_type = "GitHub"
}

resource "aws_codepipeline" "carshub_pipeline" {
  name     = "carshub-pipeline"
  role_arn = aws_iam_role.carshub_codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.carshub_codepipeline_bucket.bucket
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
        ConnectionArn    = aws_codestarconnections_connection.codepipeline_codestar_connection.arn
        FullRepositoryId = "mmdcloud/carshub-rest-ecs"
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
        ProjectName = aws_codebuild_project.carshub_build.name
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
        ClusterName = aws_ecs_cluster.carshub-cluster.name
        ServiceName = aws_ecs_service.carshub-service.name
        FileName    = "imagedefinitions.json"
      }
    }
  }
}

resource "aws_s3_bucket" "carshub_codepipeline_bucket" {
  bucket        = "theplayer007-carshub-codepipeline-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "carshub_codepipeline_bucket_pab" {
  bucket = aws_s3_bucket.carshub_codepipeline_bucket.id

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

resource "aws_iam_role" "carshub_codepipeline_role" {
  name               = "carshub_codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json
}

resource "aws_iam_role_policy_attachment" "codepipeline_ecs_full_access" {
  role       = aws_iam_role.carshub_codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
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
      aws_s3_bucket.carshub_codepipeline_bucket.arn,
      "${aws_s3_bucket.carshub_codepipeline_bucket.arn}/*"
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
    resources = [aws_codestarconnections_connection.codepipeline_codestar_connection.arn]
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
  role   = aws_iam_role.carshub_codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}
