resource "aws_acm_certificate" "default" {
  domain_name               =  element(split("/", var.default_url), 2)
  subject_alternative_names = [element(split("/", var.backend_url), 2)]
  validation_method         = "DNS"

  tags = {
    Name       = "${var.app}-${var.env}-cert"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}
