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
source  = "${dirname(find_in_parent_folders())}/..//infrastructure/modules/s3"
}

generate "provider_us-east-1" {
    path      = "provider_us-east-1.tf"
    if_exists = "overwrite"
    contents = <<EOF
provider "aws" {
  profile = "${local.common_vars.aws_profile_name}"
  region = "us-east-1"
  alias  = "us-east-1"
  default_tags {
   tags = {
     Environment = "${local.environment_vars.locals.environment}"
     Terraform   = "True"
     Terragrunt  = "True"
     Project     = "${local.common_vars.project_name}"
   }
 }
}
EOF
}

generate "provider_us-east-2" {
    path      = "provider_us-east-2.tf"
    if_exists = "overwrite"
    contents = <<EOF
provider "aws" {
  profile = "${local.common_vars.aws_profile_name}"
  region = "us-east-2"
  alias  = "us-east-2"
  default_tags {
   tags = {
     Environment = "${local.environment_vars.locals.environment}"
     Terraform   = "True"
     Terragrunt  = "True"
     Project     = "${local.common_vars.project_name}"
   }
 }
}
EOF
}




###########################################################
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
###########################################################

inputs = {
primary_bucket = "cloudfront-primary-${local.environment_vars.locals.environment}-${local.common_vars.primary_region}-${local.common_vars.project_name}"
failover_bucket = "cloudfront-failover-${local.environment_vars.locals.environment}-${local.common_vars.failover_region}-${local.common_vars.project_name}"

artifact_bucket_primary = "${local.common_vars.artifact_bucket_primary}-${local.environment_vars.locals.environment}-${local.common_vars.primary_region}-${local.common_vars.project_name}"
artifact_bucket_failover = "${local.common_vars.artifact_bucket_failover}-${local.environment_vars.locals.environment}-${local.common_vars.failover_region}-${local.common_vars.project_name}"
}
