include {
  path = find_in_parent_folders()
}
locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  # Load account, region and environment variables 
  account_vars      = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars       = read_terragrunt_config(find_in_parent_folders("region.hcl")) // Dynamically load the region from the folder name. e.g us-east-1
  environment_vars  = read_terragrunt_config(find_in_parent_folders("env.hcl")) // output will be the folder name e.g dev. prod, staging

  # Extract the variables we need with the backend configuration
  aws_region      = local.region_vars.locals.aws_region
  environment     = local.environment_vars.locals.environment // local.common_vars.environment
  account_id      = local.account_vars.locals.aws_account_id
  aws_profile     = local.account_vars.locals.aws_profile
  
}


terraform {
source  = "${dirname(find_in_parent_folders())}/..//infrastructure/modules/aws_ssm_parameter"
}


###########################################################
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
###########################################################

inputs = {
dast_key = "mysecurekey"
}
