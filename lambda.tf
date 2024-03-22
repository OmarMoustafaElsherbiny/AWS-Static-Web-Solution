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

# not recommended
data "aws_iam_policy" "dynamo_full_access_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "dynamo_full_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = data.aws_iam_policy.dynamo_full_access_policy.arn
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/src/index.py"
  output_path = "${path.module}/archive/lambda_function_payload.zip"
}

resource "aws_lambda_function" "py_lambda" {
  filename      = "${path.module}/archive/lambda_function_payload.zip"
  function_name = "dynamodb_lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.10"
  memory_size   = 1024
  timeout       = 300
}

resource "aws_lambda_function_url" "my_lambda_function_url" {
  function_name      = aws_lambda_function.py_lambda.function_name
  authorization_type = "NONE"
}

# UNIX runner script to edit index.js using sed
resource "null_resource" "edit_file" {
  provisioner "local-exec" {
    command = <<EOF
      sed -i "s|^const apiUrl =.*|const apiUrl = \"$URL\";|" ${local.build_dir}/index.js 2>/dev/null
    EOF
    environment = {
      URL = aws_lambda_function_url.my_lambda_function_url.function_url
    }
  }
  # this is needed to have script run every time
  triggers = {
    always_run = timestamp()
  }
}

# Ouput the edited file and overwrites the original
data "local_file" "edited_file" {
  depends_on = [null_resource.edit_file]
  filename   = "${local.build_dir}/index.js"
}
