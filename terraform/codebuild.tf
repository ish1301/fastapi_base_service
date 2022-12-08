resource "aws_s3_bucket" "amp_bucket" {
  bucket = "${var.app}-${var.env}-s3-bucket"
  tags = {
    Name       = "${var.app}-${var.env}-s3-bucket"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "amp_bucket_encryption" {
  bucket = aws_s3_bucket.amp_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "amp_bucket_public_access" {
  bucket = aws_s3_bucket.amp_bucket.id

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_s3_bucket_acl" "amp_acl" {
  bucket = aws_s3_bucket.amp_bucket.id
  acl    = "private"
}

resource "aws_iam_role" "amp_role" {
  name = "${var.app}-${var.env}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "amp_role_policy" {
  role = aws_iam_role.amp_role.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
        "Effect": "Allow",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ],
        "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.codepipeline_bucket.arn}",
        "${aws_s3_bucket.codepipeline_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterfacePermission"
      ],
      "Resource": [
        "arn:aws:ec2:${var.region}:${var.account_id}:network-interface/*"
      ],
      "Condition": {
        "StringEquals": {
          "ec2:Subnet": [
            "${aws_subnet.amp_public_subnet.arn}",
            "${aws_subnet.amp_private_subnet.arn}",
            "${aws_subnet.amp_alternate_public_subnet.arn}",
            "${aws_subnet.amp_alternate_private_subnet.arn}"
          ],
          "ec2:AuthorizedService": "codebuild.amazonaws.com"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.amp_bucket.arn}",
        "${aws_s3_bucket.amp_bucket.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "amp_project" {
  name          = "${var.app}-${var.env}-project"
  build_timeout = "15"
  service_role  = aws_iam_role.amp_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.account_id
    }
    environment_variable {
      name  = "DJANGO_IMAGE_NAME"
      value = local.container_django
    }
    environment_variable {
      name  = "NGINX_IMAGE_NAME"
      value = local.container_nginx
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.amp_bucket.id}/build-log"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/archerdxinc/assay-marketplace"
    git_clone_depth = 1
  }

  vpc_config {
    vpc_id = aws_vpc.amp_vpc.id

    subnets = [
      aws_subnet.amp_private_subnet.id,
      aws_subnet.amp_alternate_private_subnet.id
    ]

    security_group_ids = [
      aws_security_group.default_sg.id,
    ]
  }

  tags = {
    Name       = "${var.app}-${var.env}-codebuild-project"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}

resource "aws_codebuild_project" "amp_ui_project" {
  name          = "${var.app}-${var.env}-ui-project"
  build_timeout = "15"
  service_role  = aws_iam_role.amp_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.account_id
    }
    environment_variable {
      name  = "FRONTEND_IMAGE_NAME"
      value = local.container_frontend
    }
    environment_variable {
      name  = "REACT_APP_SERVER_URL"
      value = var.backend_url
    }
    environment_variable {
      name  = "REACT_APP_DOMAIN_GROUP_ID"
      value = var.domain_group_id
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.amp_bucket.id}/build-log"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/archerdxinc/assay-marketplace-ui"
    git_clone_depth = 1
  }

  vpc_config {
    vpc_id = aws_vpc.amp_vpc.id

    subnets = [
      aws_subnet.amp_private_subnet.id,
      aws_subnet.amp_alternate_private_subnet.id
    ]

    security_group_ids = [
      aws_security_group.default_sg.id,
    ]
  }

  tags = {
    Name       = "${var.app}-${var.env}-codebuild-ui-project"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}

