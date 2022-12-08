resource "aws_lb" "amp_main" {
  name               = "${var.app}-${var.env}-lb"
  load_balancer_type = "application"
  subnets = [aws_subnet.amp_public_subnet.id, aws_subnet.amp_alternate_public_subnet.id]
  security_groups = [aws_security_group.lb_sg.id]

  tags = {
    Name       = "${var.app}-${var.env}-lb"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}

resource "aws_lb_target_group" "amp_targetgroup" {
  name        = "${var.app}-${var.env}-tg"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.amp_vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = var.healthcheck.healthy_threshold
    unhealthy_threshold = var.healthcheck.unhealthy_threshold
    timeout             = var.healthcheck.timeout
    path                = "/docs/"
    interval            = var.healthcheck.interval
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name       = "${var.app}-${var.env}-tg"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}

resource "aws_lb_listener" "amp_listener" {
  load_balancer_arn = aws_lb.amp_main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = aws_acm_certificate.default.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.amp_targetgroup.arn
  }
}

resource "aws_lb" "amp_ui_main" {
  name               = "${var.app}-${var.env}-ui-lb"
  load_balancer_type = "application"
  subnets = [aws_subnet.amp_public_subnet.id, aws_subnet.amp_alternate_public_subnet.id]
  security_groups = [aws_security_group.lb_sg.id]

  tags = {
    Name       = "${var.app}-${var.env}-ui-lb"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}

resource "aws_lb_target_group" "amp_ui_targetgroup" {
  name        = "${var.app}-${var.env}-ui-tg"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.amp_vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold   = var.healthcheck.healthy_threshold
    unhealthy_threshold = var.healthcheck.unhealthy_threshold
    timeout             = var.healthcheck.timeout
    path                = "/"
    interval            = var.healthcheck.interval
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name       = "${var.app}-${var.env}-ui-tg"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}

resource "aws_lb_listener" "amp_ui_listener" {
  load_balancer_arn = aws_lb.amp_ui_main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = aws_acm_certificate.default.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.amp_ui_targetgroup.arn
  }
}
