# ECR 
resource "aws_ecr_repository" "carshub" {
  name                 = "carshub"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_repository" "carshub-frontend" {
  name                 = "carshub-frontend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = false
  }
}

# Bash script to build the docker image and push it to ECR
resource "null_resource" "push_to_ecr" {
  provisioner "local-exec" {
    command = "bash ${path.cwd}/../../backend/api/ecr_build_push.sh ${aws_ecr_repository.carshub.name} ${var.region} ${tostring(data.vault_generic_secret.rds.data["username"])} ${tostring(data.vault_generic_secret.rds.data["password"])} ${tostring(split(":", aws_db_instance.carshub-db.endpoint)[0])} ${aws_lb.frontend-lb.dns_name}"
  }
  depends_on = [aws_lb.frontend-lb]
}

resource "null_resource" "push_frontend_to_ecr" {
  provisioner "local-exec" {
    command = "bash ${path.cwd}/../../frontend/ecr_build_push.sh ${aws_ecr_repository.carshub-frontend.name} ${var.region} ${aws_lb.lb.dns_name} ${aws_cloudfront_distribution.carshub_vehicle_images_cloudfront_distribution.domain_name}"
  }
  depends_on = [aws_lb.lb]
}