resource "aws_s3_bucket" "site_origin" {
  bucket = var.aws_s3_bucket_name

  tags = {
    Name        = "${local.name} - my web bucket"
    Environment = local.environment
  }
}

resource "aws_s3_object" "website_build" {
  depends_on = [data.local_file.edited_file, null_resource.edit_file]
  for_each   = fileset("${local.build_dir}/", "*")
  bucket     = aws_s3_bucket.site_origin.id
  # object name
  key    = each.value
  source = "${local.build_dir}/${each.value}"
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
