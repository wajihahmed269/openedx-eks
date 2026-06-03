locals {
  db_identifier        = var.name_prefix != null ? "${var.name_prefix}-${var.name}" : var.name
  db_subnet_group_name = "${local.db_identifier}-subnet-group"
  secret_name          = var.secret_name != null ? var.secret_name : "${local.db_identifier}-credentials"
}

resource "random_password" "master" {
  length           = var.master_password_length
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name        = local.secret_name
  description = "RDS MySQL credentials for ${local.db_identifier}"

  tags = merge(
    var.tags,
    {
      Name = local.secret_name
    }
  )
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    username = var.master_username
    password = random_password.master.result
    engine   = var.engine
    host     = aws_db_instance.this.address
    port     = aws_db_instance.this.port
    dbname   = var.database_name
  })
}

resource "aws_db_subnet_group" "this" {
  name        = local.db_subnet_group_name
  description = "Private subnet group for ${local.db_identifier}"
  subnet_ids  = var.private_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = local.db_subnet_group_name
    }
  )
}

resource "aws_db_instance" "this" {
  identifier = local.db_identifier

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage_gb
  max_allocated_storage = var.max_allocated_storage_gb
  storage_type          = var.storage_type
  storage_encrypted     = true

  db_name  = var.database_name
  username = var.master_username
  password = random_password.master.result
  port     = var.port

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.rds_security_group_id]
  publicly_accessible    = false

  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot

  tags = merge(
    var.tags,
    {
      Name = local.db_identifier
    }
  )
}
