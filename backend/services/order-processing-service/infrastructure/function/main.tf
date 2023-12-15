
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
  }
}


# package and copy the function to s3 bucket
data "archive_file" "lambda_module" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = var.output_path
}

resource "aws_s3_object" "lambda_module" {
  bucket = var.bucket_id

  key    = var.s3_bucket_key
  source = data.archive_file.lambda_module.output_path

  etag = filemd5(data.archive_file.lambda_module.output_path)
}

# creating the lambda function
resource "aws_lambda_function" "lambda_module_function" {
  function_name = var.function_name

  s3_bucket = var.bucket_id
  s3_key    = aws_s3_object.lambda_module.key

  runtime     = var.runtime
  handler     = var.handler
  memory_size = var.memory_size
  timeout     = var.timeout

  source_code_hash = data.archive_file.lambda_module.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      REGION             = "ap-south-1"

    }
  }
}
# cloud watch logs for the lambda function
resource "aws_cloudwatch_log_group" "lambda_module" {
  name = "/aws/lambda/${aws_lambda_function.lambda_module_function.function_name}"
  retention_in_days = var.retention_in_days
}

# basic permission for the lambda function
resource "aws_iam_role" "lambda_exec" {
  name = var.aws_iam_role_lambda_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })

  managed_policy_arns = [aws_iam_policy.lambda_managed_policy.arn]
}

# managed policy
resource "aws_iam_policy" "lambda_managed_policy" {
  name = var.managed_policy_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = ["arn:aws:logs:*:*:*"]
      }
    ]
  })

}

# resource "aws_iam_role_policy_attachment" "lambda_policy" {
#   role       = aws_iam_role.lambda_exec.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }


