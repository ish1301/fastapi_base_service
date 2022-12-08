resource "aws_efs_file_system" "amp_efs" {
  creation_token = "${var.app}-${var.env}-efs"

  tags = {
    Name       = "${var.app}-${var.env}-efs"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}
