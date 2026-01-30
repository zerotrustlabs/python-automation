# Generate random password if not provided
# resource "random_password" "postgres_password" {
#   count   = var.db_password == null ? 1 : 0
#   length  = 16
#   special = true
# }

# Store password in AWS Secrets Manager
# resource "aws_secretsmanager_secret" "postgres_credentials" {
#   name                    = "${var.name_prefix}-postgres-credentials"
#   description             = "PostgreSQL database credentials"
#   recovery_window_in_days = 0

#   tags = var.tags
# }

# resource "aws_secretsmanager_secret_version" "postgres_credentials" {
#   secret_id = aws_secretsmanager_secret.postgres_credentials.id
#   secret_string = jsonencode({
#     username = var.db_username
#     password = var.db_password != null ? var.db_password : random_password.postgres_password[0].result
#     endpoint = aws_db_instance.postgres.endpoint
#     port     = aws_db_instance.postgres.port
#     dbname   = aws_db_instance.postgres.db_name
#   })
# }

# # PostgreSQL RDS Instance
# resource "aws_db_instance" "postgres" {
#   allocated_storage      = var.allocated_storage
#   engine                 = "postgres"
#   engine_version         = var.postgres_version
#   instance_class         = var.instance_class
#   db_name                = var.database_name
#   username               = var.db_username
#   password               = var.db_password != null ? var.db_password : random_password.postgres_password[0].result
#   vpc_security_group_ids = [aws_security_group.db_sg.id]
#   db_subnet_group_name   = aws_db_subnet_group.main.name
#   skip_final_snapshot    = var.skip_final_snapshot
#   storage_encrypted      = true
#   kms_key_id             = aws_kms_key.rds_key.arn

#   tags = var.tags
# }

# # RDS Subnet Group
# resource "aws_db_subnet_group" "main" {
#   name       = "${var.name_prefix}-subnet-group"
#   subnet_ids = var.private_subnet_ids

#   tags = var.tags
# }

# # Security Group for Database

#   tags = var.tags
# }

# # KMS Key for DB encryption at rest
# resource "aws_kms_key" "rds_key" {
#   description = "KMS key for RDS encryption"

#   tags = var.tags
# }


# locals {
#   subnets_name = toset(aws_subnet.private_subnet)
# }
# resource "random_password" "password" {
#   length           = 16
#   special          = true
#   override_special = "!#$%&*()-_=+[]{}<>:?"
# }


resource "aws_secretsmanager_secret" "db" {
  name = "flask-postgres-credentials"
}

# resource "aws_secretsmanager_secret_version" "db" {
#   secret_id = aws_secretsmanager_secret.db.id
#   secret_string = jsonencode({
#     username = var.db_user
#     password = var.db_password != null ? var.db_password: random_password.password[0].result
#   })
# }



resource aws_secretsmanager_secret_version "db"{
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode(var.secrets)

}


resource "aws_kms_key" "rds_key" {
  description = "RDS KMS key"
  tags        = var.tags
}

resource "aws_db_instance" "data_db" {
#   for_each                      = local.subnets_name
  allocated_storage             = 10
  db_name                       = "automationdb"
  engine                        = "mysql"
  engine_version                = "8.0"
  instance_class                = "db.t3.micro"
  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.rds_key.key_id
  username                      = "foo"
  db_subnet_group_name          = aws_db_subnet_group.db.name
  parameter_group_name          = "default.mysql8.0"
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot  = true
  final_snapshot_identifier = "db-automationdb"
#   depends_on = [ aws_subnet.private_subnet ]
}


data "aws_iam_policy_document" "this" {
  statement {
    sid       = "Statement1"
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    effect    = "Allow"
    resources = ["*"]
    actions   = ["secretsmanager:GetSecretValue"]
  }
}


resource aws_secretsmanager_secret_policy "db"{
  secret_arn = aws_secretsmanager_secret.db.arn
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_security_group" "db_sg" {
  name_prefix = "${aws_vpc.this.id}-db-"
  vpc_id      = aws_vpc.this.id
  description = "Security group for PostgreSQL database"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }
}