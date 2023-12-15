output "function_name" {
  description = "Name of the Lambda function."
  value       = aws_lambda_function.lambda_module_function.function_name
}

output "lambda_invoke_arn" {
  description = "Invoke Arn for the Lambda function"
  value       = aws_lambda_function.lambda_module_function.invoke_arn
}
output "lambda_arn" {
  description = "Arn for the Lambda function"
  value       = aws_lambda_function.lambda_module_function.arn
}