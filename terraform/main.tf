terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket         = "amp-mkpl-terraform-state"
    key            = "app/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "amp_locks"
    encrypt        = true
  }
}

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = var.amp_secrets_id
}

locals {
  creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}

provider "aws" {
  region = var.region
}
