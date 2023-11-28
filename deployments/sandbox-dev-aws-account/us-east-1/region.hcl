# Set common variables for the AWS Region
# This will read the current directory name as variable.
locals {
  aws_region = "${basename(get_terragrunt_dir())}"
}
