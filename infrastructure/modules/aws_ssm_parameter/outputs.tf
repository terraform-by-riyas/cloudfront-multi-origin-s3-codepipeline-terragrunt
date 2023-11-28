output "dast_key" {
    value = aws_ssm_parameter.secret.id
}