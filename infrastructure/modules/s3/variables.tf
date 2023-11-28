# variable "bucket" {
#     description = "(Optional, Forces new resource) Name of the bucket. If omitted, Terraform will assign a random, unique name. Must be lowercase and less than or equal to 63 characters in length."
# }
variable "primary_bucket" {}
variable "failover_bucket" {}
variable "artifact_bucket_primary" {}
variable "artifact_bucket_failover" {}
# variable "env" {}

