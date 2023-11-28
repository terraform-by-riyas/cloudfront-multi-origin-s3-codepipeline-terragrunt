# AWS Infra using Terraform, Terragrunt

## Very important: 

 - Step 0. Terraform uses the SSH protocol to clone the modules. Configured SSH keys will be used automatically. Add your SSH key to github account.
 - Step 1: Add AWS credentials using aws configure. Set the profile name on the account.hcl
 - Step 2: Go to aws-data folder of the deployment and run terragrunt appy command to create the state file and outputs which are required for the other modules. Otherwise the following error will get. (If the state file is exists, then this step is not required. Terraform will read the output from the state)

"Either the target module has not been applied yet, or the module has no outputs. If this is expected, set the skip_outputs flag to true on the dependency block. "

**Right formatting for github modules:** 

    terraform {
      source  = "git::git@github.com:terraform-aws-modules/terraform-aws-vpc.git//modules/vpc-endpoints?ref=v5.1.2"
    }

**Completed:** 
 - VPC with S3 endpoint (gateway) - Custom Module.
 - Spot Instance with Tagging
