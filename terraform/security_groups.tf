resource "aws_security_group" "default_sg" {
  name   = "${var.app}-${var.env}-default-sg"
  vpc_id = aws_vpc.amp_vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    self      = true
  }
  ingress {
    description     = "Inbound traffic for HTTP from load balancer"
    from_port       = 80
    protocol        = "tcp"
    to_port         = 80
    security_groups = [aws_security_group.lb_sg.id]
  }
  ingress {
      description = "Inbound traffic from VPN to db"
      from_port   = 5432
      protocol    = "tcp"
      to_port     = 5432
      cidr_blocks = ["10.0.0.0/18"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name       = "${var.app}-${var.env}-default-sg"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}

resource "aws_security_group" "lb_sg" {
  name        = "${var.app}-${var.env}-alb-sg"
  description = "Security group for inbound traffic to load balancer"
  vpc_id      = aws_vpc.amp_vpc.id

  ingress {
    description      = "Inbound traffic for HTTP"
    from_port        = 80
    protocol         = "tcp"
    to_port          = 80
    cidr_blocks = var.security_group_allowed_http_cidrs
    ipv6_cidr_blocks = var.security_group_allowed_ip6_http_cidrs
  }
  ingress {
    description      = "Inbound traffic for HTTPS"
    from_port        = 443
    protocol         = "tcp"
    to_port          = 443
    cidr_blocks = var.security_group_allowed_http_cidrs
    ipv6_cidr_blocks = var.security_group_allowed_ip6_http_cidrs
  }
  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name       = "${var.app}-${var.env}-alb-sg"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}