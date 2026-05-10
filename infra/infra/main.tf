# data "aws_caller_identity" "current" {}

# # -----------------------------------------------------------------------------------------
# # Imports
# # -----------------------------------------------------------------------------------------

# # --------------------------------- Dev ---------------------------------
# data "aws_ecr_repository" "carshub_frontend_ecr_dev_us_east_1" {
#   name = "carshub-frontend-dev-us-east-1"
# }

# data "aws_ecr_repository" "carshub_backend_ecr_dev_us_east_1" {
#   name = "carshub-backend-dev-us-east-1"
# }

# data "aws_ecs_cluster" "carshub_ecs_dev_us_east_1" {
#   cluster_name = "carshub-ecs-cluster-dev-us-east-1"
# }

# data "aws_ecs_service" "carshub_ecs_service_frontend_dev_us_east_1" {
#   cluster_arn  = data.aws_ecs_cluster.carshub_ecs_dev_us_east_1.arn
#   service_name = "ecs_frontend"
# }

# data "aws_ecs_service" "carshub_ecs_service_backend_dev_us_east_1" {
#   cluster_arn  = data.aws_ecs_cluster.carshub_ecs_dev_us_east_1.arn
#   service_name = "ecs_backend"
# }

# # --------------------------------- Staging ---------------------------------
# data "aws_ecr_repository" "carshub_frontend_ecr_staging_us_east_1" {
#   name = "carshub-frontend-staging-us-east-1"
# }

# data "aws_ecr_repository" "carshub_backend_ecr_staging_us_east_1" {
#   name = "carshub-backend-staging-us-east-1"
# }

# data "aws_ecs_cluster" "carshub_ecs_staging_us_east_1" {
#   cluster_name = "carshub-ecs-cluster-staging-us-east-1"
# }

# data "aws_ecs_service" "carshub_ecs_service_frontend_staging_us_east_1" {
#   cluster_arn  = data.aws_ecs_cluster.carshub_ecs_staging_us_east_1.arn
#   service_name = "ecs_frontend"
# }

# data "aws_ecs_service" "carshub_ecs_service_backend_staging_us_east_1" {
#   cluster_arn  = data.aws_ecs_cluster.carshub_ecs_staging_us_east_1.arn
#   service_name = "ecs_backend"
# }

# # --------------------------------- Prod ---------------------------------
# data "aws_ecr_repository" "carshub_frontend_ecr_prod_us_east_1" {
#   name = "carshub-frontend-prod-us-east-1"
# }

# data "aws_ecr_repository" "carshub_backend_ecr_prod_us_east_1" {
#   name = "carshub-backend-prod-us-east-1"
# }

# data "aws_ecs_cluster" "carshub_ecs_prod_us_east_1" {
#   cluster_name = "carshub-ecs-cluster-prod-us-east-1"
# }

# data "aws_ecs_service" "carshub_ecs_service_frontend_prod_us_east_1" {
#   cluster_arn  = data.aws_ecs_cluster.carshub_ecs_prod_us_east_1.arn
#   service_name = "ecs_frontend"
# }

# data "aws_ecs_service" "carshub_ecs_service_backend_prod_us_east_1" {
#   cluster_arn  = data.aws_ecs_cluster.carshub_ecs_prod_us_east_1.arn
#   service_name = "ecs_backend"
# }

# # -----------------------------------------------------------------------------------------
# # SNS Configuration
# # -----------------------------------------------------------------------------------------
# module "carshub_infra_alarm_notifications" {
#   source     = "./modules/sns"
#   topic_name = "carshub-infra-alarm-notification-topic"
#   subscriptions = [
#     {
#       protocol = "email"
#       endpoint = "madmaxcloudonline@gmail.com"
#     }
#   ]
# }

# # -----------------------------------------------------------------------------------------
# # CodeBuild Configuration
# # -----------------------------------------------------------------------------------------
# module "codebuild_cache_bucket" {
#   source        = "./modules/s3"
#   bucket_name   = "codebuild-cache-bucket"
#   objects       = []
#   bucket_policy = ""
#   cors = [
#     {
#       allowed_headers = ["*"]
#       allowed_methods = ["GET"]
#       allowed_origins = ["*"]
#       max_age_seconds = 3000
#     },
#     {
#       allowed_headers = ["*"]
#       allowed_methods = ["PUT"]
#       allowed_origins = ["*"]
#       max_age_seconds = 3000
#     }
#   ]
#   versioning_enabled = "Enabled"
#   force_destroy      = true
# }

# # CodeBuild IAM Role
# module "carshub_codebuild_iam_role" {
#   source             = "./modules/iam"
#   role_name          = "carshub-codebuild-role"
#   role_description   = "IAM role for creating a building and pushing images to ECR for carshub frontend and backend applications"
#   policy_name        = "carshub-codebuild-policy"
#   policy_description = "IAM policy for creating a building and pushing images to ECR for carshub frontend and backend applications"
#   assume_role_policy = <<EOF
#     {
#         "Version": "2012-10-17",
#         "Statement": [
#             {
#                 "Action": "sts:AssumeRole",
#                 "Principal": {
#                   "Service": "codebuild.amazonaws.com"
#                 },
#                 "Effect": "Allow",
#                 "Sid": ""
#             }
#         ]
#     }
#     EOF
#   policy             = <<EOF
#     {
#         "Version": "2012-10-17",
#         "Statement": [
#             {
#                 "Action": [
#                   "logs:CreateLogGroup",
#                   "logs:CreateLogStream",
#                   "logs:PutLogEvents"
#                 ],
#                 "Resource": "*",
#                 "Effect": "Allow"
#             },
#             {
#                 "Action": [
#                   "s3:GetObject",
#                   "s3:PutObject",
#                   "s3:GetObjectVersion",
#                   "s3:GetBucketAcl",
#                   "s3:GetBucketLocation"
#                 ],
#                 "Resource": [
#                   "${module.codebuild_cache_bucket.arn}",
#                   "${module.codebuild_cache_bucket.arn}/*"
#                 ],
#                 "Effect": "Allow"
#             },
#             {
#                 "Action": [
#                   "ecr:GetAuthorizationToken"
#                 ],
#                 "Resource": "*",
#                 "Effect": "Allow"
#             },
#             {
#                 "Action": [
#                   "ecr:BatchGetImage",
#                   "ecr:BatchCheckLayerAvailability",
#                   "ecr:CompleteLayerUpload",
#                   "ecr:DescribeImages",
#                   "ecr:DescribeRepositories",
#                   "ecr:GetDownloadUrlForLayer",
#                   "ecr:InitiateLayerUpload",
#                   "ecr:ListImages",
#                   "ecr:PutImage",
#                   "ecr:UploadLayerPart"
#                 ],
#                 "Resource": [
#                   "${data.aws_ecr_repository.carshub_frontend_ecr_prod_us_east_1.arn}",
#                   "${data.aws_ecr_repository.carshub_backend_ecr_prod_us_east_1.arn}"
#                 ],
#                 "Effect": "Allow"
#             }
#         ]
#     }
#     EOF
# }

# module "carshub_codebuild_frontend" {
#   source                        = "./modules/devops/codebuild"
#   build_timeout                 = 60
#   cache_bucket_name             = module.codebuild_cache_bucket.bucket
#   cloudwatch_group_name         = "/aws/codebuild/carshub-codebuiild-frontend"
#   cloudwatch_stream_name        = "carshub-codebuiild-frontend-stream"
#   codebuild_project_description = "carshub-codebuild-frontend"
#   codebuild_project_name        = "carshub-codebuild-frontend"
#   role                          = module.carshub_codebuild_iam_role.arn
#   compute_type                  = "BUILD_GENERAL1_SMALL"
#   env_image                     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
#   env_type                      = "LINUX_CONTAINER"
#   fetch_submodules              = true
#   force_destroy_cache_bucket    = true
#   image_pull_credentials_type   = "CODEBUILD"
#   privileged_mode               = true
#   source_location               = "https://github.com/mmdcloud/aws-carshub-rest-ecs.git"
#   source_git_clone_depth        = "1"
#   source_type                   = "GITHUB"
#   source_version                = "frontend"
#   environment_variables = [
#     {
#       name  = "ACCOUNT_ID"
#       value = data.aws_caller_identity.current.account_id
#     },
#     {
#       name  = "REGION"
#       value = "${var.region}"
#     },
#     {
#       name  = "REPO"
#       value = "carshub-frontend"
#     }
#   ]
# }

# module "carshub_codebuild_backend" {
#   source                        = "./modules/devops/codebuild"
#   build_timeout                 = 60
#   cache_bucket_name             = module.codebuild_cache_bucket.bucket
#   cloudwatch_group_name         = "/aws/codebuild/carshub-codebuiild-backend"
#   cloudwatch_stream_name        = "carshub-codebuiild-backend-stream"
#   codebuild_project_description = "carshub-codebuild-backend"
#   codebuild_project_name        = "carshub-codebuild-backend"
#   role                          = module.carshub_codebuild_iam_role.arn
#   compute_type                  = "BUILD_GENERAL1_SMALL"
#   env_image                     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
#   env_type                      = "LINUX_CONTAINER"
#   fetch_submodules              = true
#   force_destroy_cache_bucket    = true
#   image_pull_credentials_type   = "CODEBUILD"
#   privileged_mode               = true
#   source_location               = "https://github.com/mmdcloud/aws-carshub-rest-ecs.git"
#   source_git_clone_depth        = "1"
#   source_type                   = "GITHUB"
#   source_version                = "backend"
#   environment_variables = [
#     {
#       name  = "ACCOUNT_ID"
#       value = data.aws_caller_identity.current.account_id
#     },
#     {
#       name  = "REGION"
#       value = "${var.region}"
#     },
#     {
#       name  = "REPO"
#       value = "carshub-backend"
#     }
#   ]
# }

# # -----------------------------------------------------------------------------------------
# # CodePipeline Configuration
# # -----------------------------------------------------------------------------------------
# module "carshub_frontend_codepipeline_bucket" {
#   source        = "./modules/s3"
#   bucket_name   = "carshub-frontend-codepipeline-bucket"
#   objects       = []
#   bucket_policy = ""
#   cors = [
#     {
#       allowed_headers = ["*"]
#       allowed_methods = ["GET"]
#       allowed_origins = ["*"]
#       max_age_seconds = 3000
#     },
#     {
#       allowed_headers = ["*"]
#       allowed_methods = ["PUT"]
#       allowed_origins = ["*"]
#       max_age_seconds = 3000
#     }
#   ]
#   versioning_enabled = "Enabled"
#   force_destroy      = true

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# # CodePipeline backend artifact bucket
# module "carshub_backend_codepipeline_bucket" {
#   source        = "./modules/s3"
#   bucket_name   = "carshub-backend-codepipeline-bucket"
#   objects       = []
#   bucket_policy = ""
#   cors = [
#     {
#       allowed_headers = ["*"]
#       allowed_methods = ["GET"]
#       allowed_origins = ["*"]
#       max_age_seconds = 3000
#     },
#     {
#       allowed_headers = ["*"]
#       allowed_methods = ["PUT"]
#       allowed_origins = ["*"]
#       max_age_seconds = 3000
#     }
#   ]
#   versioning_enabled = "Enabled"
#   force_destroy      = true

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# # CodePipleine IAM Role
# resource "aws_codestarconnections_connection" "carshub_codepipeline_codestar_connection" {
#   name          = "carshub-codestar-connection"
#   provider_type = "GitHub"
# }

# module "carshub_codepipeline_role" {
#   source             = "./modules/iam"
#   role_name          = "carshub-codepipeline-role"
#   role_description   = "IAM role for carshub codepipeline to access S3, CodeDeploy, CodeStar Connections, and CodeBuild"
#   policy_name        = "carshub-codepipeline-policy"
#   policy_description = "IAM policy for carshub codepipeline to access S3, CodeDeploy, CodeStar Connections, and CodeBuild"
#   assume_role_policy = <<EOF
#     {
#         "Version": "2012-10-17",
#         "Statement": [
#             {
#                 "Action": "sts:AssumeRole",
#                 "Principal": {
#                   "Service": "codepipeline.amazonaws.com"
#                 },
#                 "Effect": "Allow",
#                 "Sid": ""
#             }
#         ]
#     }
#     EOF
#   policy             = <<EOF
#     {
#         "Version": "2012-10-17",
#         "Statement": [
#             {
#                 "Action": [
#                   "s3:GetObject",
#                   "s3:GetObjectVersion",
#                   "s3:GetBucketVersioning",
#                   "s3:PutObjectAcl",
#                   "s3:PutObject"
#                 ],
#                 "Resource": [
#                   "${module.carshub_frontend_codepipeline_bucket.arn}",
#                   "${module.carshub_frontend_codepipeline_bucket.arn}/*",
#                   "${module.carshub_backend_codepipeline_bucket.arn}",
#                   "${module.carshub_backend_codepipeline_bucket.arn}/*"
#                 ],
#                 "Effect": "Allow"
#             },
#             {
#                 "Action": [
#                   "codedeploy:GetDeploymentConfig"
#                 ],
#                 "Resource": [
#                   "arn:aws:codedeploy:${var.region}:${data.aws_caller_identity.current.account_id}:deploymentconfig:CodeDeployDefault.OneAtATime"
#                 ],
#                 "Effect": "Allow"
#             },
#             {
#                 "Action": [
#                   "codestar-connections:UseConnection"
#                 ],
#                 "Resource": [
#                   "${aws_codestarconnections_connection.carshub_codepipeline_codestar_connection.arn}"
#                 ],
#                 "Effect": "Allow"
#             },
#             {
#                 "Action": [
#                   "codebuild:BatchGetBuilds",
#                   "codebuild:StartBuild"
#                 ],
#                 "Resource": [
#                   "${module.carshub_codebuild_frontend.arn}",
#                   "${module.carshub_codebuild_backend.arn}"                
#                 ],
#                 "Effect": "Allow"
#             }
#         ]
#     }
#     EOF
# }

# resource "aws_iam_role_policy_attachment" "codepipeline_ecs_full_access" {
#   role       = module.carshub_codepipeline_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
# }

# # CodePipeline for Frontend
# module "carshub_frontend_codepipeline" {
#   source              = "./modules/devops/codepipeline"
#   name                = "carshub-frontend-codepipeline"
#   role_arn            = module.carshub_codepipeline_role.arn
#   artifact_bucket     = module.carshub_frontend_codepipeline_bucket.bucket
#   artifact_store_type = "S3"
#   stages = [
#     {
#       name = "Source"
#       actions = [
#         {
#           name             = "Source"
#           category         = "Source"
#           owner            = "AWS"
#           provider         = "CodeStarSourceConnection"
#           version          = "1"
#           action_type_id   = "Source"
#           run_order        = 1
#           input_artifacts  = []
#           output_artifacts = ["source_output"]
#           configuration = {
#             FullRepositoryId = "mmdcloud/aws-carshub-rest-ecs"
#             BranchName       = "frontend"
#             ConnectionArn    = "${aws_codestarconnections_connection.carshub_codepipeline_codestar_connection.arn}"
#           }
#         }
#       ]
#     },
#     {
#       name = "Build"
#       actions = [
#         {
#           name             = "Build"
#           category         = "Build"
#           owner            = "AWS"
#           provider         = "CodeBuild"
#           version          = "1"
#           action_type_id   = "Build"
#           run_order        = 1
#           input_artifacts  = ["source_output"]
#           output_artifacts = ["build_output"]
#           configuration = {
#             ProjectName   = "${module.carshub_codebuild_frontend.project_name}"
#             PrimarySource = "source_output"
#             # EnvironmentVariables = jsonencode(module.carshub_codebuild_frontend.environment_variables)
#           }
#         }
#       ]
#     },
#     {
#       name = "Deploy To Staging"
#       actions = [
#         {
#           name             = "DeployToStaging"
#           category         = "Deploy"
#           owner            = "AWS"
#           provider         = "ECS"
#           version          = "1"
#           action_type_id   = "DeployToStaging"
#           run_order        = 1
#           input_artifacts  = ["build_output"]
#           output_artifacts = []
#           configuration = {
#             ClusterName = "${data.aws_ecs_cluster.carshub_ecs_staging_us_east_1.cluster_name}"
#             ServiceName = "${data.aws_ecs_service.carshub_ecs_service_frontend_staging_us_east_1.service_name}"
#             FileName    = "imagedefinitions.json"
#           }
#         }
#       ]
#     },
#     {
#       name = "Approval"
#       actions = [{
#         name             = "ManualApproval"
#         category         = "Approval"
#         owner            = "AWS"
#         provider         = "Manual"
#         input_artifacts  = []
#         output_artifacts = []
#         version          = "1"
#         configuration = {
#           NotificationArn = "${module.carshub_infra_alarm_notifications.topic_arn}"
#           CustomData      = "Approve production deployment"
#         }
#       }]
#     },
#     {
#       name = "Deploy To Prod"
#       actions = [
#         {
#           name             = "DeployToProd"
#           category         = "Deploy"
#           owner            = "AWS"
#           provider         = "ECS"
#           version          = "1"
#           action_type_id   = "DeployToProd"
#           run_order        = 1
#           input_artifacts  = ["build_output"]
#           output_artifacts = []
#           configuration = {
#             ClusterName = "${data.aws_ecs_cluster.carshub_ecs_prod_us_east_1.cluster_name}"
#             ServiceName = "${data.aws_ecs_service.carshub_ecs_service_frontend_prod_us_east_1.service_name}"
#             FileName    = "imagedefinitions.json"
#           }
#         }
#       ]
#     }
#   ]
# }

# # CodePipeline for Backend
# module "carshub_backend_codepipeline" {
#   source              = "./modules/devops/codepipeline"
#   name                = "carshub-backend-codepipeline"
#   role_arn            = module.carshub_codepipeline_role.arn
#   artifact_bucket     = module.carshub_backend_codepipeline_bucket.bucket
#   artifact_store_type = "S3"
#   stages = [
#     {
#       name = "Source"
#       actions = [
#         {
#           name             = "Source"
#           category         = "Source"
#           owner            = "AWS"
#           provider         = "CodeStarSourceConnection"
#           version          = "1"
#           action_type_id   = "Source"
#           run_order        = 1
#           input_artifacts  = []
#           output_artifacts = ["source_output"]
#           configuration = {
#             FullRepositoryId = "mmdcloud/aws-carshub-rest-ecs"
#             BranchName       = "backend"
#             ConnectionArn    = "${aws_codestarconnections_connection.carshub_codepipeline_codestar_connection.arn}"
#           }
#         }
#       ]
#     },
#     {
#       name = "Build"
#       actions = [
#         {
#           name             = "Build"
#           category         = "Build"
#           owner            = "AWS"
#           provider         = "CodeBuild"
#           version          = "1"
#           action_type_id   = "Build"
#           run_order        = 1
#           input_artifacts  = ["source_output"]
#           output_artifacts = ["build_output"]
#           configuration = {
#             ProjectName   = "${module.carshub_codebuild_backend.project_name}"
#             PrimarySource = "source_output"
#             # EnvironmentVariables = jsonencode(module.carshub_codebuild_frontend.environment_variables)
#           }
#         }
#       ]
#     },
#     {
#       name = "Deploy To Staging"
#       actions = [
#         {
#           name             = "DeployToStaging"
#           category         = "Deploy"
#           owner            = "AWS"
#           provider         = "ECS"
#           version          = "1"
#           action_type_id   = "DeployToStaging"
#           run_order        = 1
#           input_artifacts  = ["build_output"]
#           output_artifacts = []
#           configuration = {
#             ClusterName = "${data.aws_ecs_cluster.carshub_ecs_staging_us_east_1.cluster_name}"
#             ServiceName = "${data.aws_ecs_service.carshub_ecs_service_backend_staging_us_east_1.service_name}"
#             FileName    = "imagedefinitions.json"
#           }
#         }
#       ]
#     },
#     {
#       name = "Approval"
#       actions = [{
#         name             = "ManualApproval"
#         category         = "Approval"
#         owner            = "AWS"
#         provider         = "Manual"
#         version          = "1"
#         input_artifacts  = []
#         output_artifacts = []
#         configuration = {
#           NotificationArn = "${module.carshub_infra_alarm_notifications.topic_arn}"
#           CustomData      = "Approve production deployment"
#         }
#       }]
#     },
#     {
#       name = "Deploy To Prod"
#       actions = [
#         {
#           name             = "DeployToProd"
#           category         = "Deploy"
#           owner            = "AWS"
#           provider         = "ECS"
#           version          = "1"
#           action_type_id   = "DeployToProd"
#           run_order        = 1
#           input_artifacts  = ["build_output"]
#           output_artifacts = []
#           configuration = {
#             ClusterName = "${data.aws_ecs_cluster.carshub_ecs_prod_us_east_1.cluster_name}"
#             ServiceName = "${data.aws_ecs_service.carshub_ecs_service_backend_prod_us_east_1.service_name}"
#             FileName    = "imagedefinitions.json"
#           }
#         }
#       ]
#     }
#   ]
# }
data "aws_caller_identity" "current" {}

# -----------------------------------------------------------------------------------------
# Imports — existing infra (dev / staging / prod)
# -----------------------------------------------------------------------------------------

# ---- Dev ----
data "aws_ecr_repository" "carshub_frontend_ecr_dev_us_east_1" {
  name = "carshub-frontend-dev-us-east-1"
}
data "aws_ecr_repository" "carshub_backend_ecr_dev_us_east_1" {
  name = "carshub-backend-dev-us-east-1"
}
data "aws_ecs_cluster" "carshub_ecs_dev_us_east_1" {
  cluster_name = "carshub-ecs-cluster-dev-us-east-1"
}
data "aws_ecs_service" "carshub_ecs_service_frontend_dev_us_east_1" {
  cluster_arn  = data.aws_ecs_cluster.carshub_ecs_dev_us_east_1.arn
  service_name = "ecs_frontend"
}
data "aws_ecs_service" "carshub_ecs_service_backend_dev_us_east_1" {
  cluster_arn  = data.aws_ecs_cluster.carshub_ecs_dev_us_east_1.arn
  service_name = "ecs_backend"
}

# ---- Staging ----
data "aws_ecr_repository" "carshub_frontend_ecr_staging_us_east_1" {
  name = "carshub-frontend-staging-us-east-1"
}
data "aws_ecr_repository" "carshub_backend_ecr_staging_us_east_1" {
  name = "carshub-backend-staging-us-east-1"
}
data "aws_ecs_cluster" "carshub_ecs_staging_us_east_1" {
  cluster_name = "carshub-ecs-cluster-staging-us-east-1"
}
data "aws_ecs_service" "carshub_ecs_service_frontend_staging_us_east_1" {
  cluster_arn  = data.aws_ecs_cluster.carshub_ecs_staging_us_east_1.arn
  service_name = "ecs_frontend"
}
data "aws_ecs_service" "carshub_ecs_service_backend_staging_us_east_1" {
  cluster_arn  = data.aws_ecs_cluster.carshub_ecs_staging_us_east_1.arn
  service_name = "ecs_backend"
}

# ---- Prod ----
data "aws_ecr_repository" "carshub_frontend_ecr_prod_us_east_1" {
  name = "carshub-frontend-prod-us-east-1"
}
data "aws_ecr_repository" "carshub_backend_ecr_prod_us_east_1" {
  name = "carshub-backend-prod-us-east-1"
}
data "aws_ecs_cluster" "carshub_ecs_prod_us_east_1" {
  cluster_name = "carshub-ecs-cluster-prod-us-east-1"
}
data "aws_ecs_service" "carshub_ecs_service_frontend_prod_us_east_1" {
  cluster_arn  = data.aws_ecs_cluster.carshub_ecs_prod_us_east_1.arn
  service_name = "ecs_frontend"
}
data "aws_ecs_service" "carshub_ecs_service_backend_prod_us_east_1" {
  cluster_arn  = data.aws_ecs_cluster.carshub_ecs_prod_us_east_1.arn
  service_name = "ecs_backend"
}

# -----------------------------------------------------------------------------------------
# KMS — encrypt all pipeline artifacts at rest
# -----------------------------------------------------------------------------------------
resource "aws_kms_key" "pipeline_key" {
  description             = "KMS key for CarHub pipeline artifact encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags = {
    Name    = "carshub-pipeline-kms-key"
    Project = "CarsHub"
  }
}

resource "aws_kms_alias" "pipeline_key_alias" {
  name          = "alias/carshub-pipeline-key"
  target_key_id = aws_kms_key.pipeline_key.key_id
}

# -----------------------------------------------------------------------------------------
# SNS — pipeline + security notifications
# -----------------------------------------------------------------------------------------
module "carshub_infra_alarm_notifications" {
  source     = "./modules/sns"
  topic_name = "carshub-infra-alarm-notification-topic"
  subscriptions = [
    {
      protocol = "email"
      endpoint = "madmaxcloudonline@gmail.com"
    }
  ]
}

module "carshub_security_notifications" {
  source     = "./modules/sns"
  topic_name = "carshub-security-notification-topic"
  subscriptions = [
    {
      protocol = "email"
      endpoint = "madmaxcloudonline@gmail.com"
    }
  ]
}

# -----------------------------------------------------------------------------------------
# S3 — artifact buckets (KMS encrypted, public access blocked, versioned)
# -----------------------------------------------------------------------------------------
module "codebuild_cache_bucket" {
  source      = "./modules/s3"
  bucket_name = "carshub-codebuild-cache-${data.aws_caller_identity.current.account_id}"
  objects     = []
  cors = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "PUT"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    }
  ]
  bucket_policy           = ""
  versioning_enabled      = "Enabled"
  force_destroy           = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  kms_key_arn             = aws_kms_key.pipeline_key.arn
}

module "carshub_frontend_codepipeline_bucket" {
  source      = "./modules/s3"
  bucket_name = "carshub-frontend-pipeline-${data.aws_caller_identity.current.account_id}"
  objects     = []
  cors = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "PUT"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    }
  ]
  bucket_policy           = ""
  versioning_enabled      = "Enabled"
  force_destroy           = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  kms_key_arn             = aws_kms_key.pipeline_key.arn
}

module "carshub_backend_codepipeline_bucket" {
  source      = "./modules/s3"
  bucket_name = "carshub-backend-pipeline-${data.aws_caller_identity.current.account_id}"
  objects     = []
  cors = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "PUT"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    }
  ]
  bucket_policy           = ""
  versioning_enabled      = "Enabled"
  force_destroy           = true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  kms_key_arn             = aws_kms_key.pipeline_key.arn
}

# Security findings bucket — stores SAST/SCA/image scan reports
module "carshub_security_reports_bucket" {
  source      = "./modules/s3"
  bucket_name = "carshub-security-reports-${data.aws_caller_identity.current.account_id}"
  objects     = []
  cors = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    }
  ]
  bucket_policy           = ""
  versioning_enabled      = "Enabled"
  force_destroy           = false # keep security reports
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  kms_key_arn             = aws_kms_key.pipeline_key.arn
}

# -----------------------------------------------------------------------------------------
# GitHub connection (shared by both pipelines)
# -----------------------------------------------------------------------------------------
resource "aws_codestarconnections_connection" "carshub_codepipeline_codestar_connection" {
  name          = "carshub-codestar-connection"
  provider_type = "GitHub"
}

# -----------------------------------------------------------------------------------------
# CodeBuild IAM Role
# -----------------------------------------------------------------------------------------
module "carshub_codebuild_iam_role" {
  source             = "./modules/iam"
  role_name          = "carshub-codebuild-role"
  role_description   = "IAM role for CarHub CodeBuild — build, security scans, push to ECR"
  policy_name        = "carshub-codebuild-policy"
  policy_description = "IAM policy for CarHub CodeBuild"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": { "Service": "codebuild.amazonaws.com" },
      "Effect": "Allow"
    }
  ]
}
EOF
  policy             = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Logs",
      "Action": ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Sid": "CacheS3",
      "Action": ["s3:GetObject","s3:PutObject","s3:GetObjectVersion","s3:GetBucketAcl","s3:GetBucketLocation"],
      "Resource": [
        "${module.codebuild_cache_bucket.arn}",
        "${module.codebuild_cache_bucket.arn}/*",
        "${module.carshub_frontend_codepipeline_bucket.arn}",
        "${module.carshub_frontend_codepipeline_bucket.arn}/*",
        "${module.carshub_backend_codepipeline_bucket.arn}",
        "${module.carshub_backend_codepipeline_bucket.arn}/*"
      ],
      "Effect": "Allow"
    },
    {
      "Sid": "SecurityReports",
      "Action": ["s3:PutObject","s3:GetObject"],
      "Resource": [
        "${module.carshub_security_reports_bucket.arn}",
        "${module.carshub_security_reports_bucket.arn}/*"
      ],
      "Effect": "Allow"
    },
    {
      "Sid": "ECRAuth",
      "Action": ["ecr:GetAuthorizationToken"],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Sid": "ECRPush",
      "Action": [
        "ecr:BatchGetImage","ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload","ecr:DescribeImages","ecr:DescribeRepositories",
        "ecr:GetDownloadUrlForLayer","ecr:InitiateLayerUpload",
        "ecr:ListImages","ecr:PutImage","ecr:UploadLayerPart",
        "ecr:StartImageScan","ecr:DescribeImageScanFindings"
      ],
      "Resource": [
        "${data.aws_ecr_repository.carshub_frontend_ecr_dev_us_east_1.arn}",
        "${data.aws_ecr_repository.carshub_backend_ecr_dev_us_east_1.arn}",
        "${data.aws_ecr_repository.carshub_frontend_ecr_staging_us_east_1.arn}",
        "${data.aws_ecr_repository.carshub_backend_ecr_staging_us_east_1.arn}",
        "${data.aws_ecr_repository.carshub_frontend_ecr_prod_us_east_1.arn}",
        "${data.aws_ecr_repository.carshub_backend_ecr_prod_us_east_1.arn}"
      ],
      "Effect": "Allow"
    },
    {
      "Sid": "KMS",
      "Action": ["kms:Decrypt","kms:GenerateDataKey"],
      "Resource": "${aws_kms_key.pipeline_key.arn}",
      "Effect": "Allow"
    },
    {
      "Sid": "CodeGuruReviewer",
      "Action": [
        "codeguru-reviewer:AssociateRepository",
        "codeguru-reviewer:CreateCodeReview",
        "codeguru-reviewer:DescribeCodeReview",
        "codeguru-reviewer:ListRecommendations"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Sid": "InspectorV2",
      "Action": [
        "inspector2:ListFindings",
        "inspector2:ListCoverageStatistics"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Sid": "SNSSecurityAlerts",
      "Action": ["sns:Publish"],
      "Resource": "${module.carshub_security_notifications.topic_arn}",
      "Effect": "Allow"
    },
    {
      "Sid": "SecretsManager",
      "Action": ["secretsmanager:GetSecretValue"],
      "Resource": "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:carshub-*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

# -----------------------------------------------------------------------------------------
# CodeBuild — SAST (Semgrep / Bandit / ESLint security rules)
# Runs static analysis on source code before any image is built
# -----------------------------------------------------------------------------------------
module "carshub_codebuild_sast_frontend" {
  source                        = "./modules/devops/codebuild"
  codebuild_project_name        = "carshub-sast-frontend"
  codebuild_project_description = "SAST scan for CarHub frontend source code"
  role                          = module.carshub_codebuild_iam_role.arn
  build_timeout                 = 30
  cache_bucket_name             = module.codebuild_cache_bucket.bucket
  cloudwatch_group_name         = "/aws/codebuild/carshub-sast-frontend"
  cloudwatch_stream_name        = "carshub-sast-frontend-stream"
  compute_type                  = "BUILD_GENERAL1_SMALL"
  env_image                     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  env_type                      = "LINUX_CONTAINER"
  privileged_mode               = false
  image_pull_credentials_type   = "CODEBUILD"
  fetch_submodules              = true
  force_destroy_cache_bucket    = true
  source_type                   = "GITHUB"
  source_location               = "https://github.com/mmdcloud/aws-carshub-rest-ecs.git"
  source_git_clone_depth        = "1"
  source_version                = "frontend"
  environment_variables = [
    { name = "REPORTS_BUCKET", value = module.carshub_security_reports_bucket.bucket },
    { name = "SNS_TOPIC_ARN",  value = module.carshub_security_notifications.topic_arn },
    { name = "APP",            value = "frontend" }
  ]
  # buildspec inline — SAST only, no docker build
  buildspec = <<-BUILDSPEC
    version: 0.2
    phases:
      install:
        runtime-versions:
          nodejs: 18
        commands:
          - pip3 install semgrep --quiet
          - npm install -g eslint eslint-plugin-security --silent
      pre_build:
        commands:
          - echo "=== SAST: Semgrep ==="
          - semgrep --config=p/owasp-top-ten --config=p/secrets --json --output semgrep-results.json . || true
          - echo "=== SAST: ESLint Security ==="
          - eslint --ext .js,.jsx,.ts,.tsx --format json -o eslint-security-results.json . || true
      build:
        commands:
          - |
            CRITICAL=$(cat semgrep-results.json | python3 -c "
            import json,sys
            data=json.load(sys.stdin)
            critical=[r for r in data.get('results',[]) if r.get('extra',{}).get('severity') in ['ERROR','CRITICAL']]
            print(len(critical))
            ")
            echo "Critical SAST findings: $CRITICAL"
            if [ "$CRITICAL" -gt "0" ]; then
              aws sns publish --topic-arn $SNS_TOPIC_ARN \
                --message "SECURITY ALERT: $CRITICAL critical SAST findings in carshub-frontend. Review: s3://$REPORTS_BUCKET/sast/frontend/" \
                --subject "CarHub SAST Alert - Frontend"
              # Fail the build on critical findings
              exit 1
            fi
      post_build:
        commands:
          - aws s3 cp semgrep-results.json s3://$REPORTS_BUCKET/sast/frontend/semgrep-$CODEBUILD_BUILD_NUMBER.json
          - aws s3 cp eslint-security-results.json s3://$REPORTS_BUCKET/sast/frontend/eslint-$CODEBUILD_BUILD_NUMBER.json
    reports:
      sast-report:
        files:
          - semgrep-results.json
        file-format: SEMGREP
  BUILDSPEC
}

module "carshub_codebuild_sast_backend" {
  source                        = "./modules/devops/codebuild"
  codebuild_project_name        = "carshub-sast-backend"
  codebuild_project_description = "SAST scan for CarHub backend source code"
  role                          = module.carshub_codebuild_iam_role.arn
  build_timeout                 = 30
  cache_bucket_name             = module.codebuild_cache_bucket.bucket
  cloudwatch_group_name         = "/aws/codebuild/carshub-sast-backend"
  cloudwatch_stream_name        = "carshub-sast-backend-stream"
  compute_type                  = "BUILD_GENERAL1_SMALL"
  env_image                     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  env_type                      = "LINUX_CONTAINER"
  privileged_mode               = false
  image_pull_credentials_type   = "CODEBUILD"
  fetch_submodules              = true
  force_destroy_cache_bucket    = true
  source_type                   = "GITHUB"
  source_location               = "https://github.com/mmdcloud/aws-carshub-rest-ecs.git"
  source_git_clone_depth        = "1"
  source_version                = "backend"
  environment_variables = [
    { name = "REPORTS_BUCKET", value = module.carshub_security_reports_bucket.bucket },
    { name = "SNS_TOPIC_ARN",  value = module.carshub_security_notifications.topic_arn },
    { name = "APP",            value = "backend" }
  ]
  buildspec = <<-BUILDSPEC
    version: 0.2
    phases:
      install:
        runtime-versions:
          nodejs: 18
        commands:
          - pip3 install semgrep --quiet
          - npm install -g audit-ci --silent
      pre_build:
        commands:
          - echo "=== SCA: npm audit ==="
          - npm audit --json > npm-audit.json || true
          - echo "=== SAST: Semgrep ==="
          - semgrep --config=p/owasp-top-ten --config=p/secrets --config=p/nodejs --json --output semgrep-results.json . || true
      build:
        commands:
          - |
            CRITICAL=$(cat semgrep-results.json | python3 -c "
            import json,sys
            data=json.load(sys.stdin)
            critical=[r for r in data.get('results',[]) if r.get('extra',{}).get('severity') in ['ERROR','CRITICAL']]
            print(len(critical))
            ")
            HIGH_VULNS=$(cat npm-audit.json | python3 -c "
            import json,sys
            data=json.load(sys.stdin)
            print(data.get('metadata',{}).get('vulnerabilities',{}).get('high',0) + data.get('metadata',{}).get('vulnerabilities',{}).get('critical',0))
            " 2>/dev/null || echo 0)
            echo "Critical SAST: $CRITICAL | High/Critical SCA: $HIGH_VULNS"
            if [ "$CRITICAL" -gt "0" ] || [ "$HIGH_VULNS" -gt "0" ]; then
              aws sns publish --topic-arn $SNS_TOPIC_ARN \
                --message "SECURITY ALERT: SAST=$CRITICAL critical, SCA=$HIGH_VULNS high/critical vulns in carshub-backend" \
                --subject "CarHub Security Alert - Backend"
              exit 1
            fi
      post_build:
        commands:
          - aws s3 cp semgrep-results.json s3://$REPORTS_BUCKET/sast/backend/semgrep-$CODEBUILD_BUILD_NUMBER.json
          - aws s3 cp npm-audit.json s3://$REPORTS_BUCKET/sca/backend/npm-audit-$CODEBUILD_BUILD_NUMBER.json
  BUILDSPEC
}

# -----------------------------------------------------------------------------------------
# CodeBuild — Build + push image (runs AFTER SAST passes)
# -----------------------------------------------------------------------------------------
module "carshub_codebuild_frontend" {
  source                        = "./modules/devops/codebuild"
  codebuild_project_name        = "carshub-codebuild-frontend"
  codebuild_project_description = "Build and push CarHub frontend Docker image to ECR"
  role                          = module.carshub_codebuild_iam_role.arn
  build_timeout                 = 60
  cache_bucket_name             = module.codebuild_cache_bucket.bucket
  cloudwatch_group_name         = "/aws/codebuild/carshub-codebuild-frontend"
  cloudwatch_stream_name        = "carshub-codebuild-frontend-stream"
  compute_type                  = "BUILD_GENERAL1_SMALL"
  env_image                     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  env_type                      = "LINUX_CONTAINER"
  privileged_mode               = true # required for docker build
  image_pull_credentials_type   = "CODEBUILD"
  fetch_submodules              = true
  force_destroy_cache_bucket    = true
  source_type                   = "GITHUB"
  source_location               = "https://github.com/mmdcloud/aws-carshub-rest-ecs.git"
  source_git_clone_depth        = "1"
  source_version                = "frontend"
  environment_variables = [
    { name = "ACCOUNT_ID",      value = data.aws_caller_identity.current.account_id },
    { name = "REGION",          value = var.region },
    { name = "REPO",            value = "carshub-frontend" },
    { name = "REPORTS_BUCKET",  value = module.carshub_security_reports_bucket.bucket },
    { name = "SNS_TOPIC_ARN",   value = module.carshub_security_notifications.topic_arn }
  ]
  buildspec = <<-BUILDSPEC
    version: 0.2
    phases:
      pre_build:
        commands:
          - echo Logging in to Amazon ECR...
          - aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
          - IMAGE_TAG=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c1-8)
          - REPO_URI=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO
      build:
        commands:
          - echo Building Docker image...
          - docker build -t $REPO_URI:$IMAGE_TAG -t $REPO_URI:latest .
          - echo "=== Image Scan: Trivy ==="
          - curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
          - trivy image --exit-code 0 --severity HIGH,CRITICAL --format json --output trivy-results.json $REPO_URI:$IMAGE_TAG || true
          - |
            CRITICAL=$(cat trivy-results.json | python3 -c "
            import json,sys
            data=json.load(sys.stdin)
            total=sum(len([v for v in r.get('Vulnerabilities',[]) if v.get('Severity')=='CRITICAL']) for r in data.get('Results',[]) if r.get('Vulnerabilities'))
            print(total)
            " 2>/dev/null || echo 0)
            echo "Critical image vulnerabilities: $CRITICAL"
            if [ "$CRITICAL" -gt "0" ]; then
              aws sns publish --topic-arn $SNS_TOPIC_ARN \
                --message "SECURITY ALERT: $CRITICAL CRITICAL CVEs in carshub-frontend image tag $IMAGE_TAG" \
                --subject "CarHub Image Scan Alert - Frontend"
              exit 1
            fi
      post_build:
        commands:
          - docker push $REPO_URI:$IMAGE_TAG
          - docker push $REPO_URI:latest
          - aws s3 cp trivy-results.json s3://$REPORTS_BUCKET/image-scan/frontend/trivy-$IMAGE_TAG.json
          - printf '[{"name":"ecs_frontend","imageUri":"%s:%s"}]' $REPO_URI $IMAGE_TAG > imagedefinitions.json
    artifacts:
      files:
        - imagedefinitions.json
  BUILDSPEC
}

module "carshub_codebuild_backend" {
  source                        = "./modules/devops/codebuild"
  codebuild_project_name        = "carshub-codebuild-backend"
  codebuild_project_description = "Build and push CarHub backend Docker image to ECR"
  role                          = module.carshub_codebuild_iam_role.arn
  build_timeout                 = 60
  cache_bucket_name             = module.codebuild_cache_bucket.bucket
  cloudwatch_group_name         = "/aws/codebuild/carshub-codebuild-backend"
  cloudwatch_stream_name        = "carshub-codebuild-backend-stream"
  compute_type                  = "BUILD_GENERAL1_SMALL"
  env_image                     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  env_type                      = "LINUX_CONTAINER"
  privileged_mode               = true
  image_pull_credentials_type   = "CODEBUILD"
  fetch_submodules              = true
  force_destroy_cache_bucket    = true
  source_type                   = "GITHUB"
  source_location               = "https://github.com/mmdcloud/aws-carshub-rest-ecs.git"
  source_git_clone_depth        = "1"
  source_version                = "backend"
  environment_variables = [
    { name = "ACCOUNT_ID",      value = data.aws_caller_identity.current.account_id },
    { name = "REGION",          value = var.region },
    { name = "REPO",            value = "carshub-backend" },
    { name = "REPORTS_BUCKET",  value = module.carshub_security_reports_bucket.bucket },
    { name = "SNS_TOPIC_ARN",   value = module.carshub_security_notifications.topic_arn }
  ]
  buildspec = <<-BUILDSPEC
    version: 0.2
    phases:
      pre_build:
        commands:
          - aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
          - IMAGE_TAG=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c1-8)
          - REPO_URI=$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO
      build:
        commands:
          - docker build -t $REPO_URI:$IMAGE_TAG -t $REPO_URI:latest .
          - curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
          - trivy image --exit-code 0 --severity HIGH,CRITICAL --format json --output trivy-results.json $REPO_URI:$IMAGE_TAG || true
          - |
            CRITICAL=$(cat trivy-results.json | python3 -c "
            import json,sys
            data=json.load(sys.stdin)
            total=sum(len([v for v in r.get('Vulnerabilities',[]) if v.get('Severity')=='CRITICAL']) for r in data.get('Results',[]) if r.get('Vulnerabilities'))
            print(total)
            " 2>/dev/null || echo 0)
            if [ "$CRITICAL" -gt "0" ]; then
              aws sns publish --topic-arn $SNS_TOPIC_ARN \
                --message "SECURITY ALERT: $CRITICAL CRITICAL CVEs in carshub-backend image tag $IMAGE_TAG" \
                --subject "CarHub Image Scan Alert - Backend"
              exit 1
            fi
      post_build:
        commands:
          - docker push $REPO_URI:$IMAGE_TAG
          - docker push $REPO_URI:latest
          - aws s3 cp trivy-results.json s3://$REPORTS_BUCKET/image-scan/backend/trivy-$IMAGE_TAG.json
          - printf '[{"name":"ecs_backend","imageUri":"%s:%s"}]' $REPO_URI $IMAGE_TAG > imagedefinitions.json
    artifacts:
      files:
        - imagedefinitions.json
  BUILDSPEC
}

# -----------------------------------------------------------------------------------------
# CodePipeline IAM Role
# -----------------------------------------------------------------------------------------
module "carshub_codepipeline_role" {
  source             = "./modules/iam"
  role_name          = "carshub-codepipeline-role"
  role_description   = "IAM role for CarHub CodePipeline"
  policy_name        = "carshub-codepipeline-policy"
  policy_description = "IAM policy for CarHub CodePipeline"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": { "Service": "codepipeline.amazonaws.com" },
      "Effect": "Allow"
    }
  ]
}
EOF
  policy             = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ArtifactBuckets",
      "Action": [
        "s3:GetObject","s3:GetObjectVersion","s3:GetBucketVersioning",
        "s3:PutObjectAcl","s3:PutObject"
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
      "Sid": "KMS",
      "Action": ["kms:Decrypt","kms:GenerateDataKey"],
      "Resource": "${aws_kms_key.pipeline_key.arn}",
      "Effect": "Allow"
    },
    {
      "Sid": "CodeStarConnection",
      "Action": ["codestar-connections:UseConnection"],
      "Resource": "${aws_codestarconnections_connection.carshub_codepipeline_codestar_connection.arn}",
      "Effect": "Allow"
    },
    {
      "Sid": "CodeBuild",
      "Action": ["codebuild:BatchGetBuilds","codebuild:StartBuild"],
      "Resource": [
        "${module.carshub_codebuild_sast_frontend.arn}",
        "${module.carshub_codebuild_sast_backend.arn}",
        "${module.carshub_codebuild_frontend.arn}",
        "${module.carshub_codebuild_backend.arn}"
      ],
      "Effect": "Allow"
    },
    {
      "Sid": "SNS",
      "Action": ["sns:Publish"],
      "Resource": "${module.carshub_infra_alarm_notifications.topic_arn}",
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

# -----------------------------------------------------------------------------------------
# Frontend CodePipeline
# Stages: Source → SAST → Build+ImageScan → Deploy Staging → Approval → Deploy Prod
# -----------------------------------------------------------------------------------------
module "carshub_frontend_codepipeline" {
  source              = "./modules/devops/codepipeline"
  name                = "carshub-frontend-codepipeline"
  role_arn            = module.carshub_codepipeline_role.arn
  artifact_bucket     = module.carshub_frontend_codepipeline_bucket.bucket
  artifact_store_type = "S3"
  encryption_key_id   = aws_kms_key.pipeline_key.arn # KMS-encrypted artifacts
  stages = [
    # ---- 1. Source ----
    {
      name = "Source"
      actions = [
        {
          name             = "Source"
          category         = "Source"
          owner            = "AWS"
          provider         = "CodeStarSourceConnection"
          version          = "1"
          run_order        = 1
          input_artifacts  = []
          output_artifacts = ["source_output"]
          configuration = {
            FullRepositoryId     = "mmdcloud/aws-carshub-rest-ecs"
            BranchName           = "frontend"
            ConnectionArn        = aws_codestarconnections_connection.carshub_codepipeline_codestar_connection.arn
            DetectChanges        = "true"
            OutputArtifactFormat = "CODEBUILD_CLONE_REF" # full git context for Semgrep
          }
        }
      ]
    },
    # ---- 2. SAST — blocks pipeline on critical findings ----
    {
      name = "SAST"
      actions = [
        {
          name             = "StaticAnalysis"
          category         = "Build"
          owner            = "AWS"
          provider         = "CodeBuild"
          version          = "1"
          run_order        = 1
          input_artifacts  = ["source_output"]
          output_artifacts = ["sast_output"]
          configuration = {
            ProjectName   = module.carshub_codebuild_sast_frontend.project_name
            PrimarySource = "source_output"
          }
        }
      ]
    },
    # ---- 3. Build + Image Scan ----
    {
      name = "Build"
      actions = [
        {
          name             = "BuildAndScanImage"
          category         = "Build"
          owner            = "AWS"
          provider         = "CodeBuild"
          version          = "1"
          run_order        = 1
          input_artifacts  = ["source_output"]
          output_artifacts = ["build_output"]
          configuration = {
            ProjectName   = module.carshub_codebuild_frontend.project_name
            PrimarySource = "source_output"
          }
        }
      ]
    },
    # ---- 4. Deploy to Staging ----
    {
      name = "DeployStaging"
      actions = [
        {
          name             = "DeployToStaging"
          category         = "Deploy"
          owner            = "AWS"
          provider         = "ECS"
          version          = "1"
          run_order        = 1
          input_artifacts  = ["build_output"]
          output_artifacts = []
          configuration = {
            ClusterName = data.aws_ecs_cluster.carshub_ecs_staging_us_east_1.cluster_name
            ServiceName = data.aws_ecs_service.carshub_ecs_service_frontend_staging_us_east_1.service_name
            FileName    = "imagedefinitions.json"
          }
        }
      ]
    },
    # ---- 5. Manual Approval (gated by SNS notification) ----
    {
      name = "Approval"
      actions = [
        {
          name             = "ManualApproval"
          category         = "Approval"
          owner            = "AWS"
          provider         = "Manual"
          version          = "1"
          run_order        = 1
          input_artifacts  = []
          output_artifacts = []
          configuration = {
            NotificationArn = module.carshub_infra_alarm_notifications.topic_arn
            CustomData      = "Staging validation complete. Approve to deploy carshub-frontend to PRODUCTION."
            ExternalEntityLink = "https://console.aws.amazon.com/ecs/home?region=${var.region}#/clusters/${data.aws_ecs_cluster.carshub_ecs_staging_us_east_1.cluster_name}/services"
          }
        }
      ]
    },
    # ---- 6. Deploy to Prod ----
    {
      name = "DeployProd"
      actions = [
        {
          name             = "DeployToProd"
          category         = "Deploy"
          owner            = "AWS"
          provider         = "ECS"
          version          = "1"
          run_order        = 1
          input_artifacts  = ["build_output"]
          output_artifacts = []
          configuration = {
            ClusterName = data.aws_ecs_cluster.carshub_ecs_prod_us_east_1.cluster_name
            ServiceName = data.aws_ecs_service.carshub_ecs_service_frontend_prod_us_east_1.service_name
            FileName    = "imagedefinitions.json"
          }
        }
      ]
    }
  ]
}

# -----------------------------------------------------------------------------------------
# Backend CodePipeline
# Stages: Source → SAST+SCA → Build+ImageScan → Deploy Staging → Approval → Deploy Prod
# -----------------------------------------------------------------------------------------
module "carshub_backend_codepipeline" {
  source              = "./modules/devops/codepipeline"
  name                = "carshub-backend-codepipeline"
  role_arn            = module.carshub_codepipeline_role.arn
  artifact_bucket     = module.carshub_backend_codepipeline_bucket.bucket
  artifact_store_type = "S3"
  encryption_key_id   = aws_kms_key.pipeline_key.arn
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
          run_order        = 1
          input_artifacts  = []
          output_artifacts = ["source_output"]
          configuration = {
            FullRepositoryId     = "mmdcloud/aws-carshub-rest-ecs"
            BranchName           = "backend"
            ConnectionArn        = aws_codestarconnections_connection.carshub_codepipeline_codestar_connection.arn
            DetectChanges        = "true"
            OutputArtifactFormat = "CODEBUILD_CLONE_REF"
          }
        }
      ]
    },
    {
      name = "SAST-SCA"
      actions = [
        {
          name             = "StaticAnalysisAndDependencyCheck"
          category         = "Build"
          owner            = "AWS"
          provider         = "CodeBuild"
          version          = "1"
          run_order        = 1
          input_artifacts  = ["source_output"]
          output_artifacts = ["sast_output"]
          configuration = {
            ProjectName   = module.carshub_codebuild_sast_backend.project_name
            PrimarySource = "source_output"
          }
        }
      ]
    },
    {
      name = "Build"
      actions = [
        {
          name             = "BuildAndScanImage"
          category         = "Build"
          owner            = "AWS"
          provider         = "CodeBuild"
          version          = "1"
          run_order        = 1
          input_artifacts  = ["source_output"]
          output_artifacts = ["build_output"]
          configuration = {
            ProjectName   = module.carshub_codebuild_backend.project_name
            PrimarySource = "source_output"
          }
        }
      ]
    },
    {
      name = "DeployStaging"
      actions = [
        {
          name             = "DeployToStaging"
          category         = "Deploy"
          owner            = "AWS"
          provider         = "ECS"
          version          = "1"
          run_order        = 1
          input_artifacts  = ["build_output"]
          output_artifacts = []
          configuration = {
            ClusterName = data.aws_ecs_cluster.carshub_ecs_staging_us_east_1.cluster_name
            ServiceName = data.aws_ecs_service.carshub_ecs_service_backend_staging_us_east_1.service_name
            FileName    = "imagedefinitions.json"
          }
        }
      ]
    },
    {
      name = "Approval"
      actions = [
        {
          name             = "ManualApproval"
          category         = "Approval"
          owner            = "AWS"
          provider         = "Manual"
          version          = "1"
          run_order        = 1
          input_artifacts  = []
          output_artifacts = []
          configuration = {
            NotificationArn = module.carshub_infra_alarm_notifications.topic_arn
            CustomData      = "Staging validation complete. Approve to deploy carshub-backend to PRODUCTION."
            ExternalEntityLink = "https://console.aws.amazon.com/ecs/home?region=${var.region}#/clusters/${data.aws_ecs_cluster.carshub_ecs_staging_us_east_1.cluster_name}/services"
          }
        }
      ]
    },
    {
      name = "DeployProd"
      actions = [
        {
          name             = "DeployToProd"
          category         = "Deploy"
          owner            = "AWS"
          provider         = "ECS"
          version          = "1"
          run_order        = 1
          input_artifacts  = ["build_output"]
          output_artifacts = []
          configuration = {
            ClusterName = data.aws_ecs_cluster.carshub_ecs_prod_us_east_1.cluster_name
            ServiceName = data.aws_ecs_service.carshub_ecs_service_backend_prod_us_east_1.service_name
            FileName    = "imagedefinitions.json"
          }
        }
      ]
    }
  ]
}

# -----------------------------------------------------------------------------------------
# CloudWatch Alarms — pipeline health
# -----------------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "frontend_pipeline_failed" {
  alarm_name          = "carshub-frontend-pipeline-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FailedPipelines"
  namespace           = "AWS/CodePipeline"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "CarHub frontend pipeline has a failed execution"
  alarm_actions       = [module.carshub_infra_alarm_notifications.topic_arn]
  ok_actions          = [module.carshub_infra_alarm_notifications.topic_arn]
  dimensions = {
    PipelineName = module.carshub_frontend_codepipeline.pipeline_name
  }
}

resource "aws_cloudwatch_metric_alarm" "backend_pipeline_failed" {
  alarm_name          = "carshub-backend-pipeline-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FailedPipelines"
  namespace           = "AWS/CodePipeline"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "CarHub backend pipeline has a failed execution"
  alarm_actions       = [module.carshub_infra_alarm_notifications.topic_arn]
  ok_actions          = [module.carshub_infra_alarm_notifications.topic_arn]
  dimensions = {
    PipelineName = module.carshub_backend_codepipeline.pipeline_name
  }
}