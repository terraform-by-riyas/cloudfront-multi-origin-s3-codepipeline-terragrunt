resource "aws_s3_bucket" "primary_bucket" {
bucket = "${var.primary_bucket}"
provider = aws.us-east-1
}
resource "aws_s3_bucket" "failover_bucket" {
bucket = "${var.failover_bucket}"
provider = aws.us-east-2
}

// Create buckets for artifacts
resource "aws_s3_bucket" "artifact_bucket_primary" {
// Create a bucket to store artifat
  bucket = var.artifact_bucket_primary  // create a bucket in the primary region to store artifacts.
  provider = aws.us-east-1
}
resource "aws_s3_bucket" "artifact_bucket_failover" {
// Create a bucket to store artifat
  bucket = var.artifact_bucket_failover  // create a bucket in the failover region to store artifacts.
  provider = aws.us-east-2
}
//
resource "aws_s3_bucket_versioning" "primary" {
    bucket = aws_s3_bucket.primary_bucket.id
    versioning_configuration {
      status = "Enabled"
    }
}
resource "aws_s3_bucket_versioning" "failover" {
    bucket = aws_s3_bucket.failover_bucket.id
    provider = aws.us-east-2                  // Bucket is in another region
    versioning_configuration {
      status = "Enabled"
    }
}


