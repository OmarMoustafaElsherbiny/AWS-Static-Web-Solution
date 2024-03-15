terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.38.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# s3 bucket
resource "aws_s3_bucket" "site_origin" {
  bucket = "cloudreslab.io"

  tags = {
    Name        = "Res - My web bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_policy" "site_origin" {
  depends_on = [data.aws_iam_policy_document.site_origin]
  bucket     = aws_s3_bucket.site_origin.id
  policy     = data.aws_iam_policy_document.site_origin.json
}

data "aws_iam_policy_document" "site_origin" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site_origin.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.bucket_access.iam_arn]
    }
  }
  statement {
    actions = ["s3:ListBucket"]
    resources = [
      aws_s3_bucket.site_origin.arn
    ]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.bucket_access.iam_arn]
    }
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
    Name        = "Res - Site distribution"
    Environment = "Dev"
  }
}

resource "aws_dynamodb_table" "site_vistors" {
  name           = "site-vistors"
  hash_key       = "Id"
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "Id"
    type = "N"
  }

  tags = {
    Name        = "Res - Site Vistors"
    Environment = "Dev"
  }

}

resource "aws_dynamodb_table_item" "viewers" {
  table_name = aws_dynamodb_table.site_vistors.name
  hash_key   = aws_dynamodb_table.site_vistors.hash_key
  item       = <<ITEM
{
  "Id": {"N": "1"},
  "Views": {"N": "0"}
}
ITEM

}
