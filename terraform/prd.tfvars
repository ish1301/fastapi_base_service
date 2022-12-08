# Environments: dev, stg, prd
env    = "prd"
account_id = "388412242909"

security_group_allowed_http_cidrs = [
  "0.0.0.0/0",
]

dev_ops_cidrs = [
  "69.151.179.239/32", # Stuart
  "99.233.208.61/32", # Ish
  "10.0.0.0/16", # Internal subnets
]

main_availability_zone      = "us-west-2a"
alternate_availability_zone = "us-west-2b"

db = {
  instance_class   = "db.t4g.large",
  engine_version   = "12.11",
  port             = "5432",
  storage          = "20",
  max_storage      = "100",
  backup_window    = "04:53-05:23",
  backup_retention = "35",
}

domain_group_id = "083a529f-69b8-43fc-bf53-f4564cfc6d07"

email_sales_team  = "adx-sales@invitae.com"
email_design_team = "mp-design@invitae.com"
email_admins      = "assay-marketplace-admins@invitae.com"
email_noreply     = "no-reply-assay-marketplace@invitae.com"

# AWS Secrets Manager key use format:
# {"DB_USER":"name","DB_PASSWORD":"pass"}
amp_secrets_id = "amp_prd_credentials"

default_url = "https://assay-marketplace-prd.archerdx.com"
backend_url = "https://assay-marketplace-api.archerdx.com/api"

vpc_cidr                      = "10.0.128.0/18"
public_subnet_cidr            = "10.0.128.0/27"
private_subnet_cidr           = "10.0.128.32/27"
alternate_public_subnet_cidr  = "10.0.128.64/27"
alternate_private_subnet_cidr = "10.0.128.96/27"

autoscale_max = 10
