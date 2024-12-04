# 输出 Lambda 函数的 ARN
output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.zoom_upload_lambda.arn
}

# 输出 Lambda 函数的名称
output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.zoom_upload_lambda.function_name
}

# 输出 API Gateway 的调用 URL
output "api_gateway_invoke_url" {
  description = "The URL of the API Gateway to invoke Lambda"
  value       = aws_api_gateway_stage.zoom_api_stage.invoke_url
}

# 输出 SNS 主题的 ARN
output "sns_topic_arn" {
  description = "The ARN of the SNS topic used for notifications"
  value       = aws_sns_topic.zoom_sns_topic.arn
}

# 输出 CloudWatch 日志组的名称
output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group for Lambda function"
  value       = aws_cloudwatch_log_group.lambda_log_group.name
}
