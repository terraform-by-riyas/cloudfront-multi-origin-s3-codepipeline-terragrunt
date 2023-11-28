include {
  path = find_in_parent_folders()
}
locals {
     region_vars       = read_terragrunt_config(find_in_parent_folders("region.hcl")) // Dynamically load the region from the folder name.
    common_vars       = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
    environment_vars  = read_terragrunt_config(find_in_parent_folders("env.hcl"))
    environment       = local.environment_vars.locals.environment // local.common_vars.environment
}

terraform {
  source  = "${dirname(find_in_parent_folders())}/..//infrastructure/modules/cloudfront"
}

dependencies {
  paths = ["../s3"]
}

dependency "s3" {
  config_path = "../s3"
}
###########################################################
# https://registry.terraform.io/modules/terraform-aws-modules/cloudfront/aws/5.1.2?tab=inputs
###########################################################

inputs = {
domain_name_primary_bucket = dependency.s3.outputs.bucket_regional_domain_name_primary
domain_name_failover_2_bucket = dependency.s3.outputs.bucket_regional_domain_name_failover_bucket
comment = "ACDP CloudFront for the project ${local.common_vars.project_name}, ${local.common_vars.environment} environment and for account #${get_aws_account_id()}"
env = "${local.common_vars.environment}"
origin_access_control_name = "oac-policy-${local.common_vars.project_name}-${local.environment_vars.locals.environment}"
}
