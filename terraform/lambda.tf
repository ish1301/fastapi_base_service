resource "aws_iam_role" "lambda_role" {
  name = "${var.app}-${var.env}-lambda-role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.app}-${var.env}-lambda-policy"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Action": [
            "iam:GetRole",
            "iam:PassRole"
        ],
        "Resource": "arn:aws:iam::${var.account_id}:role/*",
        "Effect": "Allow"
    },
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecs:RunTask",
        "ecs:ListServices",
        "ecs:DescribeTasks",
        "ecs:DescribeServices",
        "ecs:UpdateService",
        "ecs:DescribeTaskDefinition",
        "ecs:ListTaskDefinitions",
        "ecs:ListTaskDefinitionFamilies",
        "ecs:RegisterTaskDefinition",
        "ecs:DeregisterTaskDefinition"
      ],
      "Resource": [
        "*"
      ]
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
        "codepipeline:PutJobSuccessResult",
        "codepipeline:PutJobFailureResult"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:ListTagsForResource"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_lambda_policy_to_lambda_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/python/index.py"
  output_path = "${path.module}/python/index.zip"
}

resource "aws_lambda_function" "terraform_lambda_func" {
  filename         = "${path.module}/python/index.zip"
  function_name    = "deploy_ecs_service-${var.app}-${var.env}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.9"
  depends_on       = [aws_iam_role_policy_attachment.attach_lambda_policy_to_lambda_role]
  source_code_hash = data.archive_file.lambda.output_base64sha256

  tags = {
    Name       = "${var.app}-${var.env}-lambda-func"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }

  environment {
    variables = {
      App           = var.app
      Env           = var.env
      Subnet        = aws_subnet.amp_private_subnet.id
      SubnetAlt     = aws_subnet.amp_alternate_private_subnet.id
      SecurityGroup = aws_security_group.default_sg.id
    }
  }
}
