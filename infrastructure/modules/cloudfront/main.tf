# resource "aws_s3_bucket" "b" {
#   bucket = "mybucket-temp-jhfsjfhsjfj-dhakdhada"

#   tags = {
#     Name = "My bucket"
#   }
# }

resource "aws_cloudfront_origin_access_control" "default" {
  name                              = var.origin_access_control_name
  description                       = "Policy created by Terraform"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
  }

locals {
  s3_origin_id = "myS3Origin"
}


resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled             = true
  retain_on_delete    = false
  staging             = false   // variable
  is_ipv6_enabled     = true
  comment             = var.comment
  default_root_object = "index.html"
  wait_for_deployment = false
  
 

  origin_group {
    origin_id = "originGroupS3"

    failover_criteria {
      status_codes = [400, 403, 404, 416, 500, 502, 503, 504]
    }

    member {
      origin_id = "primary_bucket"
    }

    member {
      origin_id = "failover_bucket"
    }

  }
  

  origin {
    domain_name = var.domain_name_primary_bucket
    origin_id   = "primary_bucket"
    origin_access_control_id  = aws_cloudfront_origin_access_control.default.id

  #   s3_origin_config {
      
  #   }
  }

  origin {
    domain_name = var.domain_name_failover_2_bucket
    origin_id   = "failover_bucket"
    origin_access_control_id  = aws_cloudfront_origin_access_control.default.id

    # s3_origin_config {
    #   origin_access_control_id  = aws_cloudfront_origin_access_control.default.id
    # }
  }
  
  # AWS Managed Caching Policy (CachingOptimized)
  # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html
  default_cache_behavior {
    # Using the CachingOptimized managed policy ID:
    cache_policy_id  = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "originGroupS3"
    compress         = true // CachingOptimized Policy is caching enabled. Supports Gzip and Brotli compression.
    
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  // Customized Cache
  
  # default_cache_behavior {
  #   allowed_methods  = ["GET", "HEAD", "OPTIONS"]
  #   cached_methods   = ["GET", "HEAD"]
  #   target_origin_id = "originGroupS3"

  #   forwarded_values {
  #     query_string = false

  #     cookies {
  #       forward = "none"
  #     }
  #   }

  #   viewer_protocol_policy = "redirect-to-https"
  #   min_ttl                = 0
  #   default_ttl            = 3600
  #   max_ttl                = 86400
  # }

viewer_certificate {
    cloudfront_default_certificate = true
  }
  
    price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
}

resource "aws_cloudfront_origin_access_identity" "this" {}

