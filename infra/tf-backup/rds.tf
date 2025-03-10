# RDS Instance
resource "aws_db_instance" "carshub-db" {
  allocated_storage   = 20
  db_name             = var.db_name
  engine              = "mysql"
  engine_version      = "8.0"
  publicly_accessible = true
  multi_az            = false  
  instance_class      = "db.t3.micro"
  # db_subnet_group_name = aws_db_subnet_group.carshub_rds_subnet_group.name
  # vpc_security_group_ids = [aws_db_subnet_group.carshub_rds_subnet_group.id]
  username             = tostring(data.vault_generic_secret.rds.data["username"])
  password             = tostring(data.vault_generic_secret.rds.data["password"])
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}

# resource "aws_db_subnet_group" "carshub_rds_subnet_group" {
#   name       = "carshub-rds-subnet-group"
#   subnet_ids = aws_subnet.public_subnets[*].id

#   tags = {
#     Name = "carshub-rds-subnet-group"
#   }
# }