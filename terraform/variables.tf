variable "region" {
  description = "AWS region to use"
  default = "us-west-2"
}
variable "account_id" {
  description = "AWS ACCOUNT ID to use"
}
variable "app" {
  description = "App Name to be used in AWS tags"
  default     = "amp"
}
variable "security_group_allowed_http_cidrs" {
  description = "Allowed HTTP cidrs"
  type        = list(string)
}

variable "security_group_allowed_ip6_http_cidrs" {
  description = "Allowed IP6 HTTP cidrs"
  type        = list(string)
  default     = []
}
variable "dev_ops_cidrs" {
  description = "The array of cidr's that should be able to create SSH tunnel to DB"
}
variable "main_availability_zone" {
  description = "the availability zone where things will reside"
}
variable "alternate_availability_zone" {
  description = "the application load balancer wants us to specify a second availability zone"
}
variable "ami" {
  description = "ami for marketplace"
  default     = "ami-0e5b6b6a9f3db6db8" # Amazon Linux 2 - 64-bit x86
}
variable "key_name" {
  description = "key pair name for ec2 ssh access"
  default     = "assay_marketplace"
}
variable "env" {
  description = "Environment for deployment"
}
variable "vpc_cidr" {
  description = "cidr block for the marketplace vpc"
}
variable "public_subnet_cidr" {
  description = "cidr block for the first public subnet, must be at minimum /27"
}
variable "private_subnet_cidr" {
  description = "cidr block for the first private subnet, must be at minimum /27"
}
variable "alternate_public_subnet_cidr" {
  description = "cidr block for the second public subnet, must be at minimum /27"
}
variable "alternate_private_subnet_cidr" {
  description = "cidr block for the second private subnet, must be at minimum /27"
}
variable "db" {
  description = "Database settings for AWS RDS"
}
variable "amp_secrets_id" {
  description = "Name of the AWS Secrets Manager Secret we will use to look up secrets for current deployment"
}
variable "healthcheck" {
  description = "Healthcheck settings for ECS services"
  default = {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }
}
variable "default_url" {
  description = "Default root URL of the marketplace portal"
}
variable "backend_url" {
  description = "Default API URL of the marketplace portal"
}
variable "email_sales_team" {
  description = "Email address of sales team"
}
variable "email_design_team" {
  description = "Email address of design team"
}
variable "email_admins" {
  description = "Email address of site admins"
}
variable "email_noreply" {
  description = "No reply email address"
}
variable "domain_group_id" {
  description = "Domain group ID for cookie bot"
}
variable "autoscale_max" {
  description = "Max number of autoscale backend services"
}
