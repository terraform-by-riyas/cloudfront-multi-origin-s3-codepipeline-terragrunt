output "aws_region" {
  description = "Details about selected AWS region"
  value       = data.aws_region.selected
}
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
output "account_id_suffix" {
  value = substr(data.aws_caller_identity.current.account_id, -5, -1)
}