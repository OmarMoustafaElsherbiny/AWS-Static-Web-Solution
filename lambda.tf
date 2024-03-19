resource "aws_iam_role" "lambda_role" {
  name = "py_lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/src/index.py"
  output_path = "${path.module}/archive/lambda_function_payload.zip"
}

resource "aws_lambda_function" "ts_lambda" {
  filename      = "${path.module}/archive/lambda_function_payload.zip"
  function_name = "dynamodb_lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.10"
  memory_size   = 1024
  timeout       = 300
}
