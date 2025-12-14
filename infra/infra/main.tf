data "aws_caller_identity" "current" {}

# -----------------------------------------------------------------------------------------
# CodeBuild Configuration
# -----------------------------------------------------------------------------------------
module "codebuild_cache_bucket" {
  source        = "./modules/s3"
  bucket_name   = "codebuild-cache-bucket"
  objects       = []
  bucket_policy = ""
  cors = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    },
    {
      allowed_headers = ["*"]
      allowed_methods = ["PUT"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    }
  ]
  versioning_enabled = "Enabled"
  force_destroy      = true
}

# CodeBuild IAM Role
module "carshub_codebuild_iam_role" {
  source             = "./modules/iam"
  role_name          = "carshub-codebuild-role"
  role_description   = "IAM role for creating a building and pushing images to ECR for carshub frontend and backend applications"
  policy_name        = "carshub-codebuild-policy"
  policy_description = "IAM policy for creating a building and pushing images to ECR for carshub frontend and backend applications"
  assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Principal": {
                  "Service": "codebuild.amazonaws.com"
                },
                "Effect": "Allow",
                "Sid": ""
            }
        ]
    }
    EOF
  policy             = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": [
                  "logs:CreateLogGroup",
                  "logs:CreateLogStream",
                  "logs:PutLogEvents"
                ],
                "Resource": "*",
                "Effect": "Allow"
            },
            {
                "Action": [
                  "s3:GetObject",
                  "s3:PutObject",
                  "s3:GetObjectVersion",
                  "s3:GetBucketAcl",
                  "s3:GetBucketLocation"
                ],
                "Resource": [
                  "${module.codebuild_cache_bucket.arn}",
                  "${module.codebuild_cache_bucket.arn}/*"
                ],
                "Effect": "Allow"
            },
            {
                "Action": [
                  "ecr:GetAuthorizationToken"
                ],
                "Resource": "*",
                "Effect": "Allow"
            },
            {
                "Action": [
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
                ],
                "Resource": [
                  "${module.carshub_frontend_container_registry.arn}",
                  "${module.carshub_backend_container_registry.arn}"
                ],
                "Effect": "Allow"
            }
        ]
    }
    EOF
}

module "carshub_codebuild_frontend" {
  source                        = "./modules/devops/codebuild"
  build_timeout                 = 60
  cache_bucket_name             = module.codebuild_cache_bucket.bucket
  cloudwatch_group_name         = "/aws/codebuild/carshub-codebuiild-frontend"
  cloudwatch_stream_name        = "carshub-codebuiild-frontend-stream"
  codebuild_project_description = "carshub-codebuild-frontend"
  codebuild_project_name        = "carshub-codebuild-frontend"
  role                          = module.carshub_codebuild_iam_role.arn
  compute_type                  = "BUILD_GENERAL1_SMALL"
  env_image                     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  env_type                      = "LINUX_CONTAINER"
  fetch_submodules              = true
  force_destroy_cache_bucket    = true
  image_pull_credentials_type   = "CODEBUILD"
  privileged_mode               = true
  source_location               = "https://github.com/mmdcloud/aws-carshub-rest-ecs.git"
  source_git_clone_depth        = "1"
  source_type                   = "GITHUB"
  source_version                = "frontend"
  environment_variables = [
    {
      name  = "ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    },
    {
      name  = "REGION"
      value = "${var.region}"
    },
    {
      name  = "REPO"
      value = "carshub-frontend"
    }
  ]
}

module "carshub_codebuild_backend" {
  source                        = "./modules/devops/codebuild"
  build_timeout                 = 60
  cache_bucket_name             = module.codebuild_cache_bucket.bucket
  cloudwatch_group_name         = "/aws/codebuild/carshub-codebuiild-backend"
  cloudwatch_stream_name        = "carshub-codebuiild-backend-stream"
  codebuild_project_description = "carshub-codebuild-backend"
  codebuild_project_name        = "carshub-codebuild-backend"
  role                          = module.carshub_codebuild_iam_role.arn
  compute_type                  = "BUILD_GENERAL1_SMALL"
  env_image                     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  env_type                      = "LINUX_CONTAINER"
  fetch_submodules              = true
  force_destroy_cache_bucket    = true
  image_pull_credentials_type   = "CODEBUILD"
  privileged_mode               = true
  source_location               = "https://github.com/mmdcloud/aws-carshub-rest-ecs.git"
  source_git_clone_depth        = "1"
  source_type                   = "GITHUB"
  source_version                = "backend"
  environment_variables = [
    {
      name  = "ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    },
    {
      name  = "REGION"
      value = "${var.region}"
    },
    {
      name  = "REPO"
      value = "carshub-backend"
    }
  ]
}

# -----------------------------------------------------------------------------------------
# CodePipeline Configuration
# -----------------------------------------------------------------------------------------
module "carshub_frontend_codepipeline_bucket" {
  source        = "./modules/s3"
  bucket_name   = "carshub-frontend-codepipeline-bucket"
  objects       = []
  bucket_policy = ""
  cors = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    }
  ]
  versioning_enabled = "Enabled"
  force_destroy      = true

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CodePipeline backend artifact bucket
module "carshub_backend_codepipeline_bucket" {
  source        = "./modules/s3"
  bucket_name   = "carshub-backend-codepipeline-bucket"
  objects       = []
  bucket_policy = ""
  cors = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    }
  ]
  versioning_enabled = "Enabled"
  force_destroy      = true

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CodePipleine IAM Role
resource "aws_codestarconnections_connection" "carshub_codepipeline_codestar_connection" {
  name          = "carshub-codestar-connection"
  provider_type = "GitHub"
}

module "carshub_codepipeline_role" {
  source             = "./modules/iam"
  role_name          = "carshub-codepipeline-role"
  role_description   = "IAM role for carshub codepipeline to access S3, CodeDeploy, CodeStar Connections, and CodeBuild"
  policy_name        = "carshub-codepipeline-policy"
  policy_description = "IAM policy for carshub codepipeline to access S3, CodeDeploy, CodeStar Connections, and CodeBuild"
  assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Principal": {
                  "Service": "codepipeline.amazonaws.com"
                },
                "Effect": "Allow",
                "Sid": ""
            }
        ]
    }
    EOF
  policy             = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": [
                  "s3:GetObject",
                  "s3:GetObjectVersion",
                  "s3:GetBucketVersioning",
                  "s3:PutObjectAcl",
                  "s3:PutObject"
                ],
                "Resource": [
                  "${module.carshub_frontend_codepipeline_bucket.arn}",
                  "${module.carshub_frontend_codepipeline_bucket.arn}/*",
                  "${module.carshub_backend_codepipeline_bucket.arn}",
                  "${module.carshub_backend_codepipeline_bucket.arn}/*"
                ],
                "Effect": "Allow"
            },
            {
                "Action": [
                  "codedeploy:GetDeploymentConfig"
                ],
                "Resource": [
                  "arn:aws:codedeploy:${var.region}:${data.aws_caller_identity.current.account_id}:deploymentconfig:CodeDeployDefault.OneAtATime"
                ],
                "Effect": "Allow"
            },
            {
                "Action": [
                  "codestar-connections:UseConnection"
                ],
                "Resource": [
                  "${aws_codestarconnections_connection.carshub_codepipeline_codestar_connection.arn}"
                ],
                "Effect": "Allow"
            },
            {
                "Action": [
                  "codebuild:BatchGetBuilds",
                  "codebuild:StartBuild"
                ],
                "Resource": [
                  "${module.carshub_codebuild_frontend.arn}",
                  "${module.carshub_codebuild_backend.arn}"                
                ],
                "Effect": "Allow"
            }
        ]
    }
    EOF
}

resource "aws_iam_role_policy_attachment" "codepipeline_ecs_full_access" {
  role       = module.carshub_codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

# CodePipeline for Frontend
module "carshub_frontend_codepipeline" {
  source              = "./modules/devops/codepipeline"
  name                = "carshub-frontend-codepipeline"
  role_arn            = module.carshub_codepipeline_role.arn
  artifact_bucket     = module.carshub_frontend_codepipeline_bucket.bucket
  artifact_store_type = "S3"
  stages = [
    {
      name = "Source"
      actions = [
        {
          name             = "Source"
          category         = "Source"
          owner            = "AWS"
          provider         = "CodeStarSourceConnection"
          version          = "1"
          action_type_id   = "Source"
          run_order        = 1
          input_artifacts  = []
          output_artifacts = ["source_output"]
          configuration = {
            FullRepositoryId = "mmdcloud/aws-carshub-rest-ecs"
            BranchName       = "frontend"
            ConnectionArn    = "${aws_codestarconnections_connection.carshub_codepipeline_codestar_connection.arn}"
          }
        }
      ]
    },
    {
      name = "Build"
      actions = [
        {
          name             = "Build"
          category         = "Build"
          owner            = "AWS"
          provider         = "CodeBuild"
          version          = "1"
          action_type_id   = "Build"
          run_order        = 1
          input_artifacts  = ["source_output"]
          output_artifacts = ["build_output"]
          configuration = {
            ProjectName   = "${module.carshub_codebuild_frontend.project_name}"
            PrimarySource = "source_output"
            # EnvironmentVariables = jsonencode(module.carshub_codebuild_frontend.environment_variables)
          }
        }
      ]
    },
    {
      name = "Approval"
      actions = [{
        name             = "ManualApproval"
        category         = "Approval"
        owner            = "AWS"
        provider         = "Manual"
        input_artifacts  = []
        output_artifacts = []
        version          = "1"
        configuration = {
          NotificationArn = "${module.carshub_alarm_notifications.topic_arn}"
          CustomData      = "Approve production deployment"
        }
      }]
    },
    {
      name = "Deploy"
      actions = [
        {
          name             = "DeployToECS"
          category         = "Deploy"
          owner            = "AWS"
          provider         = "ECS"
          version          = "1"
          action_type_id   = "DeployToECS"
          run_order        = 1
          input_artifacts  = ["build_output"]
          output_artifacts = []
          configuration = {
            ClusterName = "${module.carshub_cluster.cluster_name}"
            ServiceName = "${module.carshub_cluster.services["ecs-frontend"].name}"
            FileName    = "imagedefinitions.json"
          }
        }
      ]
    }
  ]
}

# CodePipeline for Backend
module "carshub_backend_codepipeline" {
  source              = "./modules/devops/codepipeline"
  name                = "carshub-backend-codepipeline"
  role_arn            = module.carshub_codepipeline_role.arn
  artifact_bucket     = module.carshub_backend_codepipeline_bucket.bucket
  artifact_store_type = "S3"
  stages = [
    {
      name = "Source"
      actions = [
        {
          name             = "Source"
          category         = "Source"
          owner            = "AWS"
          provider         = "CodeStarSourceConnection"
          version          = "1"
          action_type_id   = "Source"
          run_order        = 1
          input_artifacts  = []
          output_artifacts = ["source_output"]
          configuration = {
            FullRepositoryId = "mmdcloud/aws-carshub-rest-ecs"
            BranchName       = "backend"
            ConnectionArn    = "${aws_codestarconnections_connection.carshub_codepipeline_codestar_connection.arn}"
          }
        }
      ]
    },
    {
      name = "Build"
      actions = [
        {
          name             = "Build"
          category         = "Build"
          owner            = "AWS"
          provider         = "CodeBuild"
          version          = "1"
          action_type_id   = "Build"
          run_order        = 1
          input_artifacts  = ["source_output"]
          output_artifacts = ["build_output"]
          configuration = {
            ProjectName   = "${module.carshub_codebuild_backend.project_name}"
            PrimarySource = "source_output"
            # EnvironmentVariables = jsonencode(module.carshub_codebuild_frontend.environment_variables)
          }
        }
      ]
    },
    {
      name = "Approval"
      actions = [{
        name             = "ManualApproval"
        category         = "Approval"
        owner            = "AWS"
        provider         = "Manual"
        version          = "1"
        input_artifacts  = []
        output_artifacts = []
        configuration = {
          NotificationArn = "${module.carshub_alarm_notifications.topic_arn}"
          CustomData      = "Approve production deployment"
        }
      }]
    },
    {
      name = "Deploy"
      actions = [
        {
          name             = "DeployToECS"
          category         = "Deploy"
          owner            = "AWS"
          provider         = "ECS"
          version          = "1"
          action_type_id   = "DeployToECS"
          run_order        = 1
          input_artifacts  = ["build_output"]
          output_artifacts = []
          configuration = {
            ClusterName = "${module.carshub_cluster.cluster_name}"
            ServiceName = "${module.carshub_cluster.services["ecs-backend"].name}"
            FileName    = "imagedefinitions.json"
          }
        }
      ]
    }
  ]
}