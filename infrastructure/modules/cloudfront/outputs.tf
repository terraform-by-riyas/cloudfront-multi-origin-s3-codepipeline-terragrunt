output "distribution_id" {
    value = aws_cloudfront_distribution.s3_distribution.id
}
output "distribution_arn" {
    value = aws_cloudfront_distribution.s3_distribution.arn
}