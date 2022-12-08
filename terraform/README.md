# Terraform marketplace resources

```
export AWS_ACCESS_KEY_ID="<access key id>"
export AWS_SECRET_ACCESS_KEY="<secret key>"
terraform workspace new stg
terraform workspace select stg
terraform plan -var-file="stg.tfvars"
terraform apply -var-file="stg.tfvars"
```
Important Notes: 
* We will need to select different cidr blocks for production in order to 
  continue using the same stage jenkins instance.
* Creating the RDS instance in the private subnet will simplify later configuration
  with the application.
* For each new environment, create a new set of environment variables to take the
  place of `"stg.tfvars"` above. And then, the `terraform workspace new <new env>` command
  is run to create a new local workspace for that new environment.
* Terraform is in theory idempotent. But as we are creating the VPC peering connections manually,
  if you run terraform a second time after creating the peer connections, they will be wiped out,
  along with the associated route table and security group changes made to support the peering
  connections.
* To show current terraform workspace `$ terraform workspace show`
