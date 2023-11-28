# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  account_name   = "Development"
  aws_account_id = enter-the-12-digit-aws-account-id-here
  aws_profile    = "your-aws-profile-name-here"
}