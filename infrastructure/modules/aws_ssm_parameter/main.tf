resource "aws_ssm_parameter" "secret" {
  name        = "/CodeBuild/hawk/api/key1"
  description = "DAST Scanner API"
  type        = "SecureString"
  value       = var.dast_key
  lifecycle {
    ignore_changes = [value]
  }
}