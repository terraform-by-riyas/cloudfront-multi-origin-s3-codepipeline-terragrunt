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
  source  = "${dirname(find_in_parent_folders())}/..//infrastructure/modules/codepipeline"
}

dependencies {
  paths = ["../s3"]
}

dependency "s3" {
  config_path = "../s3"
}

########################################################
# 
###########################################################

inputs = {
environment = local.common_vars.environment
project = local.common_vars.project_name
codepipeline_name = "${local.common_vars.client_name}-${local.environment_vars.locals.environment}-${local.common_vars.project_name}-${local.common_vars.pipeline_name}" # acpd-prod-frontend-pipeline
aws_codestarconnections_connection_arn = "${local.common_vars.aws_codestarconnections_connection_arn}"
FullRepositoryId = "${local.common_vars.FullRepositoryId}"
BranchName = "${local.common_vars.BranchName}"
CodeBuildName= "${local.common_vars.client_name}-${local.environment_vars.locals.environment}-${local.common_vars.project_name}-${local.common_vars.CodeBuildName}"
primary_bucket_name = dependency.s3.outputs.primary_bucket_name
failover_bucket_name = dependency.s3.outputs.failover_bucket_name
artifact_bucket_primary = dependency.s3.outputs.artifact_bucket_primary
artifact_bucket_failover = dependency.s3.outputs.artifact_bucket_failover
artifact_bucket_primary_arn = dependency.s3.outputs.artifact_bucket_primary_arn
artifact_bucket_failover_arn = dependency.s3.outputs.artifact_bucket_failover_arn
buildspecName = "./aws-buildspec.yml"

}
