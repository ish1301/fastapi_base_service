locals {
  is_prd = var.env == "prd" ? true : false
  is_stg = var.env == "stg" ? true : false
}

resource "aws_codepipeline" "codepipeline" {
  name     = "${var.app}-${var.env}-codepipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "SourceFrontend"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output_frontend"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.default.arn
        FullRepositoryId = "archerdxinc/assay-marketplace-ui"
        BranchName       = local.is_prd || local.is_stg ? "main" : "develop"
      }
    }

    action {
      name             = "SourceBackend"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output_backend"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.default.arn
        FullRepositoryId = "archerdxinc/assay-marketplace"
        BranchName       = local.is_prd || local.is_stg ? "main" : "develop"
      }
    }
  }

  dynamic "stage" {
     for_each = local.is_prd ? [1] : []
     content {
       name = "Approve"
       action {
         configuration = {
         }
         name     = "Production-Approval"
         category = "Approval"
         owner    = "AWS"
         provider = "Manual"
         version  = "1"
       }
     }
  }

  stage {
    name = "Build"

    action {
      name             = "BuildFrontend"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output_frontend"]
      output_artifacts = []
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.amp_ui_project.name
      }
    }

    action {
      name             = "BuildBackend"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output_backend"]
      output_artifacts = []
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.amp_project.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Invoke"
      owner           = "AWS"
      provider        = "Lambda"
      input_artifacts = []
      version         = "1"

      configuration = {
        FunctionName = aws_lambda_function.terraform_lambda_func.function_name
      }
    }
  }

}

resource "aws_codestarconnections_connection" "default" {
  name          = "${var.app}-${var.env}-connection"
  provider_type = "GitHub"
  tags = {
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.app}-${var.env}-codepipeline-s3-bucket"
  tags = {
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}

resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  acl    = "private"
}

resource "aws_iam_role" "codepipeline_role" {
  name = "${var.app}-${var.env}-codepipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${var.app}-${var.env}-codepipeline-policy"
  role = aws_iam_role.codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObjectAcl",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.codepipeline_bucket.arn}",
        "${aws_s3_bucket.codepipeline_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codestar-connections:UseConnection"
      ],
      "Resource": "${aws_codestarconnections_connection.default.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": "${aws_lambda_function.terraform_lambda_func.arn}"
    }
  ]
}
EOF
}

resource "aws_kms_key" "cp_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}
resource "aws_s3_bucket_server_side_encryption_configuration" "cp_encrypt_config" {
  bucket = aws_s3_bucket.codepipeline_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.cp_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
