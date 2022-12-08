resource "aws_db_instance" "psql_db_instance" {
  allocated_storage         = var.db.storage
  max_allocated_storage     = var.db.max_storage
  storage_type              = "gp2"
  engine                    = "Postgres"
  engine_version            = var.db.engine_version
  instance_class            = var.db.instance_class
  db_name                   = "${var.app}db${var.env}"
  identifier                = "${var.app}db${var.env}"
  username                  = local.creds.DB_USER
  password                  = local.creds.DB_PASSWORD
  port                      = var.db.port
  vpc_security_group_ids    = [aws_security_group.default_sg.id]
  db_subnet_group_name      = aws_db_subnet_group.psql_db_subnet_group.name
  final_snapshot_identifier = "${var.app}-${var.env}-final-snap"
  publicly_accessible       = "false"
  deletion_protection       = "true"
  storage_encrypted         = "true"
  apply_immediately         = "true"
  backup_retention_period   = var.db.backup_retention
  backup_window             = var.db.backup_window

  tags = {
    Name       = "${var.app}-${var.env}-rds"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}

resource "aws_db_subnet_group" "psql_db_subnet_group" {
  name       = "${var.app}-${var.env}-rds-subnet-group"
  subnet_ids = [aws_subnet.amp_private_subnet.id, aws_subnet.amp_alternate_private_subnet.id]

  tags = {
    Name       = "${var.app}-${var.env}-rds-subnet-group"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}
