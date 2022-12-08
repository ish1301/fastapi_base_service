resource "aws_ssm_parameter" "debug" {
  name  = "${var.app}-${var.env}-debug"
  type  = "String"
  value = "0"

  tags = {
    Name       = "${var.app}-${var.env}-debug"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}
resource "aws_ssm_parameter" "db_name" {
  name  = "${var.app}-${var.env}-db-name"
  type  = "SecureString"
  value = aws_db_instance.psql_db_instance.db_name

  tags = {
    Name       = "${var.app}-${var.env}-db-name"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}
resource "aws_ssm_parameter" "db_user" {
  name  = "${var.app}-${var.env}-db-user"
  type  = "SecureString"
  value = local.creds.DB_USER

  tags = {
    Name       = "${var.app}-${var.env}-db-user"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}
resource "aws_ssm_parameter" "db_password" {
  name  = "${var.app}-${var.env}-db-password"
  type  = "SecureString"
  value = local.creds.DB_PASSWORD

  tags = {
    Name       = "${var.app}-${var.env}-db-password"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}
resource "aws_ssm_parameter" "db_host" {
  name  = "${var.app}-${var.env}-db-host"
  type  = "SecureString"
  value = aws_db_instance.psql_db_instance.address

  tags = {
    Name       = "${var.app}-${var.env}-db-host"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}
resource "aws_ssm_parameter" "secret_key" {
  name  = "${var.app}-${var.env}-secret-key"
  type  = "SecureString"
  value = "change-me"

  tags = {
    Name       = "${var.app}-${var.env}-secret-key"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}
resource "aws_ssm_parameter" "production" {
  name  = "${var.app}-${var.env}-production"
  type  = "String"
  value = "0"

  tags = {
    Name       = "${var.app}-${var.env}-production"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}
resource "aws_ssm_parameter" "reset_password_url" {
  name  = "${var.app}-${var.env}-reset-password-url"
  type  = "String"
  value = "${var.default_url}/reset-password"

  tags = {
    Name       = "${var.app}-${var.env}-reset-password-url"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}
resource "aws_ssm_parameter" "frontend_url" {
  name  = "${var.app}-${var.env}-frontend-url"
  type  = "String"
  value = var.default_url
  tags = {
    Name       = "${var.app}-${var.env}-frontend-url"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}
resource "aws_ssm_parameter" "email_sales_team" {
  name  = "${var.app}-${var.env}-email-sales-team"
  type  = "String"
  value = var.email_sales_team

  tags = {
    Name       = "${var.app}-${var.env}-email-sales-team"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}
resource "aws_ssm_parameter" "email_design_team" {
  name  = "${var.app}-${var.env}-email-design-team"
  type  = "String"
  value = var.email_design_team

  tags = {
    Name       = "${var.app}-${var.env}-email-design-team"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}
resource "aws_ssm_parameter" "email_admins" {
  name  = "${var.app}-${var.env}-email-admins"
  type  = "String"
  value = var.email_admins

  tags = {
    Name       = "${var.app}-${var.env}-email-admins"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}
resource "aws_ssm_parameter" "email_noreply" {
  name  = "${var.app}-${var.env}-email-noreply"
  type  = "String"
  value = var.email_noreply

  tags = {
    Name       = "${var.app}-${var.env}-email-noreply"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}
