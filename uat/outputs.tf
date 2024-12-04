output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = module.zoom_to_s3.lambda_function_arn
}

output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = module.zoom_to_s3.lambda_function_name
}

output "api_gateway_invoke_url" {
  description = "The URL of the API Gateway to invoke Lambda"
  value       = module.zoom_to_s3.api_gateway_invoke_url
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic used for notifications"
  value       = module.zoom_to_s3.sns_topic_arn
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group for Lambda function"
  value       = module.zoom_to_s3.cloudwatch_log_group_name
}
