resource "aws_iam_role" "ecs_task_role" {
  name = "${var.app}-${var.env}-ecsTaskRole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "amp_role_policy" {
  name        = "${var.app}-${var.env}-task-role-policy"
  description = "Policy that allows access to AWS resources"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": [
        "rds:*"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetAuthorizationToken"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": "arn:aws:ssm:*:${var.account_id}:parameter/${var.app}-${var.env}*",
      "Action": [
        "ssm:GetParametersByPath",
        "ssm:GetParameters",
        "ssm:GetParameter"
      ]
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.amp_role_policy.arn
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.app}-${var.env}-ecsTaskExecutionRole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}
resource "aws_iam_policy" "ecs_task_execution_policy" {
  name = "${var.app}-${var.env}-ecsTaskExecutionRole-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetAuthorizationToken"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": "arn:aws:ssm:*:${var.account_id}:parameter/${var.app}-${var.env}*",
      "Action": [
        "ssm:GetParametersByPath",
        "ssm:GetParameters",
        "ssm:GetParameter"
      ]
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
}


resource "aws_ecr_repository" "amp_django" {
  name                 = "${var.app}-${var.env}-backend-django"
  image_tag_mutability = "MUTABLE"
  tags = {
    Name       = "${var.app}-${var.env}-ecr-repo-django"
    App        = var.app
    Env        = var.env
  }
}
resource "aws_ecr_repository" "amp_nginx" {
  name                 = "${var.app}-${var.env}-backend-nginx"
  image_tag_mutability = "MUTABLE"
  tags = {
    Name       = "${var.app}-${var.env}-ecr-repo-nginx"
    App        = var.app
    Env        = var.env
  }
}
resource "aws_ecr_repository" "amp_ui" {
  name                 = "${var.app}-${var.env}-frontend"
  image_tag_mutability = "MUTABLE"
  tags = {
    Name       = "${var.app}-${var.env}-ecr-repo-frontend"
    App        = var.app
    Env        = var.env
  }
}
resource "aws_ecr_lifecycle_policy" "django" {
  repository = aws_ecr_repository.amp_django.name

  policy = jsonencode({
    rules = [{
        rulePriority = 1
        description  = "Keep last 30 images"
        action = {
          type = "expire"
        }
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }
      },
      {
      rulePriority = 2
      description  = "Expire images older than 2 days"
      action = {
        type = "expire"
      }
      selection = {
        tagStatus     = "untagged"
        countType     = "sinceImagePushed"
        countUnit     = "days"
        countNumber   = 2
      }
    }]
  })
}
resource "aws_ecr_lifecycle_policy" "nginx" {
  repository = aws_ecr_repository.amp_nginx.name

  policy = jsonencode({
    rules = [{
        rulePriority = 1
        description  = "Keep last 30 images"
        action = {
          type = "expire"
        }
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }
      },
      {
      rulePriority = 2
      description  = "Expire images older than 2 days"
      action = {
        type = "expire"
      }
      selection = {
        tagStatus     = "untagged"
        countType     = "sinceImagePushed"
        countUnit     = "days"
        countNumber   = 2
      }
    }]
  })
}
resource "aws_ecr_lifecycle_policy" "frontend" {
  repository = aws_ecr_repository.amp_ui.name

  policy = jsonencode({
    rules = [{
        rulePriority = 1
        description  = "Keep last 30 images"
        action = {
          type = "expire"
        }
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }
      },
      {
      rulePriority = 2
      description  = "Expire images older than 2 days"
      action = {
        type = "expire"
      }
      selection = {
        tagStatus     = "untagged"
        countType     = "sinceImagePushed"
        countUnit     = "days"
        countNumber   = 2
      }
    }]
  })
}

resource "aws_ecs_cluster" "amp_cluster" {
  name = "${var.app}-${var.env}-cluster"

  tags = {
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}

locals {
  container_django        = "${var.app}-${var.env}-backend-django"
  container_nginx         = "${var.app}-${var.env}-backend-nginx"
  container_frontend      = "${var.app}-${var.env}-frontend"
  container_nginx_port    = 80
  container_django_port   = 8000
  container_frontend_port = 80
}

resource "aws_ecs_task_definition" "amp_console" {
  family                   = "${var.app}-${var.env}-console"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 4096
  memory                   = 16384
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([{
      name      = local.container_django
      image     = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${local.container_django}:latest"
      essential = true
      cpu       = 4096
      memory    = 16384
      secrets = [
        {
          "name" : "DEBUG",
          "valueFrom" : aws_ssm_parameter.debug.arn
        },
        {
          "name" : "DB_NAME",
          "valueFrom" : aws_ssm_parameter.db_name.arn
        },
        {
          "name" : "DB_USER",
          "valueFrom" : aws_ssm_parameter.db_user.arn
        },
        {
          "name" : "DB_PASSWORD",
          "valueFrom" : aws_ssm_parameter.db_password.arn
        },
        {
          "name" : "DB_HOST",
          "valueFrom" : aws_ssm_parameter.db_host.arn
        },
        {
          "name" : "SECRET_KEY",
          "valueFrom" : aws_ssm_parameter.secret_key.arn
        },
        {
          "name" : "PRODUCTION",
          "valueFrom" : aws_ssm_parameter.production.arn
        },
        {
          "name" : "RESET_PASSWORD_URL",
          "valueFrom" : aws_ssm_parameter.reset_password_url.arn
        },
        {
          "name" : "FRONTEND_URL",
          "valueFrom" : aws_ssm_parameter.frontend_url.arn
        },
        {
          "name" : "DESIGN_TEAM_LIST_EMAIL",
          "valueFrom" : aws_ssm_parameter.email_design_team.arn
        },
        {
          "name" : "DISTRIBUTION_LIST_EMAIL",
          "valueFrom" : aws_ssm_parameter.email_sales_team.arn
        },
        {
          "name" : "MARKETPLACE_ADMINS_EMAIL",
          "valueFrom" : aws_ssm_parameter.email_admins.arn
        },
        {
          "name" : "NO_REPLY_EMAIL_SENDER",
          "valueFrom" : aws_ssm_parameter.email_noreply.arn
        }
      ]
      portMappings = [{
        protocol      = "tcp"
        containerPort = local.container_django_port
        hostPort      = local.container_django_port
      }],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group" : aws_cloudwatch_log_group.amp_django.name,
          "awslogs-region" : var.region,
          "awslogs-stream-prefix" : "ecs"
        }
      }
  }])
  tags = {
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}

resource "aws_ecs_task_definition" "amp_api" {
  family                   = "${var.app}-${var.env}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 8192
  memory                   = 40960
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([
    {
      name      = local.container_nginx
      image     = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${local.container_nginx}:latest"
      essential = true
      memoryReservation = 8192
      portMappings = [{
        protocol      = "tcp"
        containerPort = local.container_nginx_port
        hostPort      = local.container_nginx_port
      }],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group" : aws_cloudwatch_log_group.amp_nginx.name,
          "awslogs-region" : var.region,
          "awslogs-stream-prefix" : "ecs"
        }
      }
    },
    {
      name      = local.container_django
      image     = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${local.container_django}:latest"
      essential = true
      memoryReservation = 32768
      secrets = [
        {
          "name" : "DEBUG",
          "valueFrom" : aws_ssm_parameter.debug.arn
        },
        {
          "name" : "DB_NAME",
          "valueFrom" : aws_ssm_parameter.db_name.arn
        },
        {
          "name" : "DB_USER",
          "valueFrom" : aws_ssm_parameter.db_user.arn
        },
        {
          "name" : "DB_PASSWORD",
          "valueFrom" : aws_ssm_parameter.db_password.arn
        },
        {
          "name" : "DB_HOST",
          "valueFrom" : aws_ssm_parameter.db_host.arn
        },
        {
          "name" : "SECRET_KEY",
          "valueFrom" : aws_ssm_parameter.secret_key.arn
        },
        {
          "name" : "PRODUCTION",
          "valueFrom" : aws_ssm_parameter.production.arn
        },
        {
          "name" : "RESET_PASSWORD_URL",
          "valueFrom" : aws_ssm_parameter.reset_password_url.arn
        },
        {
          "name" : "FRONTEND_URL",
          "valueFrom" : aws_ssm_parameter.frontend_url.arn
        },
        {
          "name" : "DESIGN_TEAM_LIST_EMAIL",
          "valueFrom" : aws_ssm_parameter.email_design_team.arn
        },
        {
          "name" : "DISTRIBUTION_LIST_EMAIL",
          "valueFrom" : aws_ssm_parameter.email_sales_team.arn
        },
        {
          "name" : "MARKETPLACE_ADMINS_EMAIL",
          "valueFrom" : aws_ssm_parameter.email_admins.arn
        },
        {
          "name" : "NO_REPLY_EMAIL_SENDER",
          "valueFrom" : aws_ssm_parameter.email_noreply.arn
        }
      ]
      portMappings = [{
        protocol      = "tcp"
        containerPort = local.container_django_port
        hostPort      = local.container_django_port
      }],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group" : aws_cloudwatch_log_group.amp_django.name,
          "awslogs-region" : var.region,
          "awslogs-stream-prefix" : "ecs"
        }
      }
  }])
  tags = {
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}

resource "aws_ecs_task_definition" "amp_ui" {
  family                   = "${var.app}-${var.env}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 4096
  memory                   = 8192
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([
    {
      name      = local.container_frontend
      image     = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${local.container_frontend}:latest"
      essential = true
      cpu       = 4096
      memory    = 8192
      environment = [
        {
          "name" : "REACT_APP_SERVER_URL",
          "value" : var.backend_url
        }
      ],
      portMappings = [{
        protocol      = "tcp"
        containerPort = local.container_frontend_port
        hostPort      = local.container_frontend_port
      }],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group" : aws_cloudwatch_log_group.amp_ui.name,
          "awslogs-region" : var.region,
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ])
  tags = {
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}

resource "aws_ecs_service" "amp_backend" {
  name                = "${var.app}_${var.env}_backend"
  cluster             = aws_ecs_cluster.amp_cluster.id
  task_definition     = aws_ecs_task_definition.amp_api.arn
  desired_count       = 1
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"
  depends_on          = [aws_iam_policy.amp_role_policy]

  network_configuration {
    security_groups  = [aws_security_group.default_sg.id]
    subnets          = [aws_subnet.amp_private_subnet.id, aws_subnet.amp_alternate_private_subnet.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.amp_targetgroup.arn
    container_name   = local.container_nginx
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

  tags = {
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}

resource "aws_ecs_service" "amp_ui" {
  name                = "${var.app}_${var.env}_frontend"
  cluster             = aws_ecs_cluster.amp_cluster.id
  task_definition     = aws_ecs_task_definition.amp_ui.arn
  desired_count       = 1
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"
  depends_on          = [aws_iam_policy.amp_role_policy]

  network_configuration {
    security_groups  = [aws_security_group.default_sg.id]
    subnets          = [aws_subnet.amp_private_subnet.id, aws_subnet.amp_alternate_private_subnet.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.amp_ui_targetgroup.arn
    container_name   = local.container_frontend
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

  tags = {
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}

resource "aws_cloudwatch_log_group" "amp_nginx" {
  name = "${var.app}-${var.env}-backend-nginx-logs"

  tags = {
    Name       = "${var.app}-${var.env}-ecs-backend-nginx-logs"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}
resource "aws_cloudwatch_log_group" "amp_django" {
  name = "${var.app}-${var.env}-backend-django-logs"

  tags = {
    Name       = "${var.app}-${var.env}-ecs-backend-django-logs"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}
resource "aws_cloudwatch_log_group" "amp_ui" {
  name = "${var.app}-${var.env}-frontend-logs"

  tags = {
    Name       = "${var.app}-${var.env}-ecs-frontend-logs"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}

resource "aws_appautoscaling_target" "ecs_target_backend" {
  max_capacity = var.autoscale_max
  min_capacity = 1
  resource_id = "service/${aws_ecs_cluster.amp_cluster.name}/${aws_ecs_service.amp_backend.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_target_cpu" {
  name =   "${var.app}-${var.env}-app-scaling-policy-cpu"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.ecs_target_backend.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target_backend.scalable_dimension
  service_namespace = aws_appautoscaling_target.ecs_target_backend.service_namespace
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 60
  }
  depends_on = [aws_appautoscaling_target.ecs_target_backend]
}

resource "aws_appautoscaling_policy" "ecs_target_memory" {
  name = "${var.app}-${var.env}-app-scaling-policy-memory"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.ecs_target_backend.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target_backend.scalable_dimension
  service_namespace = aws_appautoscaling_target.ecs_target_backend.service_namespace
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = 80
  }
  depends_on = [aws_appautoscaling_target.ecs_target_backend]
}