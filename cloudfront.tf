# Cloudfornt distribution and it's OAC and OAI
resource "aws_cloudfront_distribution" "s3_distribution" {
  depends_on          = [aws_s3_bucket.site_origin, aws_cloudfront_origin_access_identity.bucket_access]
  enabled             = true
  default_root_object = "index.html"
  origin {
    domain_name = aws_s3_bucket.site_origin.bucket_domain_name
    origin_id   = aws_s3_bucket.site_origin.id
    # origin_access_control_id = aws_cloudfront_origin_access_control.site_access.id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.bucket_access.cloudfront_access_identity_path
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.site_origin.id
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
  tags = {
    Name        = "${local.name} - site distribution"
    Environment = local.environment
  }
}


# The Legacy way
resource "aws_cloudfront_origin_access_identity" "bucket_access" {
  comment = "origin access identity"
}

# The recommended way
# resource "aws_cloudfront_origin_access_control" "site_access" {
#   name                              = "s3-origin-access-control"
#   description                       = "S3 origin access control"
#   origin_access_control_origin_type = "s3"
#   signing_behavior                  = "always"
#   signing_protocol                  = "sigv4"
# }
