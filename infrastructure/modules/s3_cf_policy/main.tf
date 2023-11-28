resource "aws_s3_bucket_policy" "primary" {
  provider = aws.us-east-1
  bucket = var.primary_bucket_name
  policy = data.aws_iam_policy_document.allow_access_from_cloudfront.json
}

resource "aws_s3_bucket_policy" "failover" {
  provider = aws.us-east-2
  bucket = var.failover_2_bucket_name
  policy = data.aws_iam_policy_document.allow_access_from_cloudfront_failover.json
}

data "aws_iam_policy_document" "allow_access_from_cloudfront" {
  statement {
    actions = [ "s3:GetObject" ]
    resources = [ "${var.primary_bucket_arn}/*"]
    principals {
      type = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test = "StringEquals"
      variable = "AWS:SourceArn"
      values = [var.distribution_arn]
    }
  }
}

data "aws_iam_policy_document" "allow_access_from_cloudfront_failover" {
  statement {
    actions = [ "s3:GetObject" ]
    resources = [ "${var.failover_2_bucket_arn}/*"]
    principals {
      type = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test = "StringEquals"
      variable = "AWS:SourceArn"
      values = [var.distribution_arn]
    }
  }
}

