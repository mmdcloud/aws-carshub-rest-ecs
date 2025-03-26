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
