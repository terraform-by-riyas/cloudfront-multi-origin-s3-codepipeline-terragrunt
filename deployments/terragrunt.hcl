/******************************
TERRAGRUNT CONFIGURATION
******************************/

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

# Configure the Terragrunt remote state to utilize a S3 bucket and state lock information in a DynamoDB table. 
# And encrypt the state data.
remote_state {
  backend   = "s3"
  generate  = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config    = {
    bucket         = "${local.common_vars.state_bucket}-${local.account_id}"
    key            = "${local.common_vars.project_name}/${local.environment_vars.locals.environment}/${path_relative_to_include()}/terraform.tfstate"
    region         = "${local.common_vars.state_bucket_region}" // static - read from yaml file.
    encrypt        = true
    dynamodb_table = "${local.common_vars.dynamodb_table}"
    profile        = "${local.aws_profile}"
  }
}

# Combine all account, region and environment variables as Terragrunt input parameters.
# The input parameters can be used in Terraform configurations as Terraform variables.  
inputs = merge(
  local.account_vars.locals,
  local.region_vars.locals,
  local.environment_vars.locals,
)

terraform {
  extra_arguments "aws_profile" {
    commands = [
      "init",
      "apply",
      "refresh",
      "import",
      "plan",
      "taint",
      "untaint"
    ]

    env_vars = {
      AWS_PROFILE = "${local.common_vars.aws_profile_name}"
    }
  }
}

generate "provider" {
    path      = "provider.tf"
    if_exists = "overwrite"
    contents = <<EOF
provider "aws" {
  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${local.account_id}"]
  profile = "${local.aws_profile}"
  region = "${local.aws_region}"
  
  default_tags {
   tags = {
     Environment = "${local.environment}"
     Terraform   = "True"
     Terragrunt  = "True"
     Project     = "${local.common_vars.project_name}"
   }
 }
}
EOF
}
