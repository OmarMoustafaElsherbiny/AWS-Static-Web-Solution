resource "aws_s3_bucket" "site_origin" {
  bucket = var.aws_s3_bucket_name

  tags = {
    Name        = "${local.name} - My web bucket"
    Environment = local.environment
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
