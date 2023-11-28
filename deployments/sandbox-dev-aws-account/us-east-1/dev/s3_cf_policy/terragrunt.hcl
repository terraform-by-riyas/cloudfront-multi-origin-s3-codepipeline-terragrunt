include {
  path = find_in_parent_folders()
}
locals {
  common_vars = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
}

terraform {
source  = "${dirname(find_in_parent_folders())}/..//infrastructure/modules/s3_cf_policy"
}
dependencies {
  paths = ["../s3", "../cloudfront"]
}

dependency "s3" {
  config_path = "../s3"
}

dependency "cloudfront" {
  config_path = "../cloudfront"
}



###########################################################
# https://registry.terraform.io/providers/hashicorp/aws/3.4.0/docs/resources/s3_bucket_policy
###########################################################

inputs = {
aws_account_id = get_aws_account_id() // Terragrunt Function
primary_bucket_arn = dependency.s3.outputs.primary_bucket_arn
failover_2_bucket_arn = dependency.s3.outputs.failover_bucket_arn
primary_bucket_name = dependency.s3.outputs.primary_bucket_name
failover_2_bucket_name = dependency.s3.outputs.failover_bucket_name
distribution_id = dependency.cloudfront.outputs.distribution_id
distribution_arn = dependency.cloudfront.outputs.distribution_arn
}
