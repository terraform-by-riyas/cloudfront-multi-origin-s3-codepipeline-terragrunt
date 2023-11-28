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
source  = "${dirname(find_in_parent_folders())}/..//infrastructure/modules/s3"
}

dependencies {
  paths = ["../aws-data"]
}

dependency "aws-data" {
  config_path = "../aws-data"
}

generate "provider_us-east-1" {
    path      = "provider_us-east-1.tf"
    if_exists = "overwrite"
    contents = <<EOF
provider "aws" {
# Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${local.account_id}"]
  profile = "${local.aws_profile}"
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
    # Only these AWS Account IDs may be operated on by this template
allowed_account_ids = ["${local.account_id}"]
  profile = "${local.aws_profile}"
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
primary_bucket = "cloudfront-primary-${dependency.aws-data.outputs.account_id_suffix}-${local.environment_vars.locals.environment}-${local.common_vars.primary_region}-${local.common_vars.project_name}"
failover_bucket = "cloudfront-failover-${dependency.aws-data.outputs.account_id_suffix}-${local.environment_vars.locals.environment}-${local.common_vars.failover_region}-${local.common_vars.project_name}"

artifact_bucket_primary = "${local.common_vars.artifact_bucket_primary}-${dependency.aws-data.outputs.account_id_suffix}-${local.environment_vars.locals.environment}-${local.common_vars.primary_region}-${local.common_vars.project_name}"
artifact_bucket_failover = "${local.common_vars.artifact_bucket_failover}-${dependency.aws-data.outputs.account_id_suffix}-${local.environment_vars.locals.environment}-${local.common_vars.failover_region}-${local.common_vars.project_name}"
}
