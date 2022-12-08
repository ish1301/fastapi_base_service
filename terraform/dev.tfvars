# Environments: dev, stg, prd
env    = "dev"
account_id = "388412242909"

security_group_allowed_http_cidrs = [
  "50.224.128.200/29", # Elle Boulder
  "50.207.204.4/30", # Elle Boulder Office
  "73.223.93.208/32", # Casey Geaney
  "207.126.92.19/32", # Jon
  "73.212.167.119/32", # Chris
  "69.151.179.239/32", # Stuart
  "24.4.91.117/32", # J Ireland
  "47.28.16.222/32", # J Ireland
  "71.247.210.15/32", # Sam
  "99.233.208.61/32", # Ish
  "108.28.52.184/32", # Shilpa
  "71.255.234.235/32", # Shilpa DC
  "65.246.53.231/32", # Shilpa Maryland
]

dev_ops_cidrs = [
  "69.151.179.239/32", # Stuart
  "99.233.208.61/32", # Ish
  "10.0.0.0/16", # Internal subnets
]

main_availability_zone      = "us-west-2a"
alternate_availability_zone = "us-west-2b"

db = {
  instance_class   = "db.t4g.small",
  engine_version   = "12.11",
  port             = "5432",
  storage          = "20",
  max_storage      = "40",
  backup_window    = "04:53-05:23",
  backup_retention = "7",
}

domain_group_id = "083a529f-69b8-43fc-bf53-f4564cfc6d07"

email_sales_team  = "invitae-test-saleslist@5amsolutions.com"
email_design_team = "invitae-test-designlist@5amsolutions.com"
email_admins      = "shilpa.gorfine@invitae.com"
email_noreply     = "no-reply-assay-marketplace@invitae.com"

# AWS Secrets Manager key use format:
# {"DB_USER":"name","DB_PASSWORD":"pass"}
amp_secrets_id = "amp_dev_credentials"

default_url = "https://dev-amp.marketplace.archerdx.com"
backend_url = "https://dev-amp-api.marketplace.archerdx.com/api"

vpc_cidr                      = "10.0.0.0/18"
public_subnet_cidr            = "10.0.0.0/27"
private_subnet_cidr           = "10.0.0.32/27"
alternate_public_subnet_cidr  = "10.0.1.0/27"
alternate_private_subnet_cidr = "10.0.1.32/27"

autoscale_max = 5
