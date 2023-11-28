output "bucket_regional_domain_name_primary" {
     value = aws_s3_bucket.primary_bucket.bucket_regional_domain_name
 }
output "bucket_regional_domain_name_failover_bucket" {
     value = aws_s3_bucket.failover_bucket.bucket_regional_domain_name
 }
  output "primary_bucket_arn" {
     value = aws_s3_bucket.primary_bucket.arn
 }
  output "failover_bucket_arn" {
     value = aws_s3_bucket.failover_bucket.arn
 }
  output "primary_bucket_name" {
     value = aws_s3_bucket.primary_bucket.id
 }
  output "failover_bucket_name" {
     value = aws_s3_bucket.failover_bucket.id
 }
output "artifact_bucket_primary" {
 value = aws_s3_bucket.artifact_bucket_primary.bucket
}
output "artifact_bucket_failover" {
 value = aws_s3_bucket.artifact_bucket_failover.bucket
}
output "artifact_bucket_primary_arn" {
 value = aws_s3_bucket.artifact_bucket_primary.arn
}
output "artifact_bucket_failover_arn" {
 value = aws_s3_bucket.artifact_bucket_failover.arn
}