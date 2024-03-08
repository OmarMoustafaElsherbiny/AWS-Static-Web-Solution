terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.38.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# s3 bucket
resource "aws_s3_bucket" "site_origin" {
  bucket = "web.cloud.resume.s3.bucket"

  tags = {
    Name        = "My web bucket"
    Environment = "Dev"
  }
}

resource "aws_cloudfront_origin_access_control" "site_access" {
  name                              = "s3-origin-access-control"
  description                       = "S3 origin access control"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  depends_on = [ aws_s3_bucket.site_origin, aws_cloudfront_origin_access_control.site_access ]
  enabled = true
  # default_root_object = "index.html"
  origin {
    domain_name = aws_s3_bucket.site_origin.bucket_domain_name
    origin_id = aws_s3_bucket.site_origin.id
    origin_access_control_id = aws_cloudfront_origin_access_control.site_access.id
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  default_cache_behavior {
    allowed_methods = [ "GET", "HEAD" ]
    cached_methods = [ "GET", "HEAD" ]
    target_origin_id = aws_s3_bucket.site_origin.id
    viewer_protocol_policy = "https-only"
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}


# depends_on = [
#     azurerm_storage_account.st,
#     azurerm_mssql_server.sql
#  ]



# resource "aws_cloudfront_distribution" "s3_distribution" {
#   depends_on = [ aws_s3_bucket.site_origin ]
#   enabled = true
#   default_root_object = "index.html"
#   default_cache_behavior {
#     allowed_methods = [ "GET", "HEAD" ]
#     cached_methods = [ "GET", "HEAD" ]
#     target_origin_id = aws_s3_bucket.site_origin.id
#     viewer_protocol_policy = "https-only"
#   }
#   origin {
#     domain_name = aws_s3_bucket.site_origin.bucket_domain_name
#     origin_id = aws_s3_bucket.site_origin.id
#     origin_access_control_id = 
#   }
# }