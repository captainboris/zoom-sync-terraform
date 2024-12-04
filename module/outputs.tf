output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.zoom_upload_lambda.arn
}

output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.zoom_upload_lambda.function_name
}

output "api_gateway_invoke_url" {
  description = "The URL of the API Gateway to invoke Lambda"
  value       = aws_api_gateway_stage.zoom_api_stage.invoke_url
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic used for notifications"
  value       = aws_sns_topic.zoom_sns_topic.arn
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group for Lambda function"
  value       = aws_cloudwatch_log_group.lambda_log_group.name
}
