variable "s3_bucket_name" {
  type        = string
  description = "The name of the existing S3 bucket to upload recordings"
}

variable "sns_topic_name" {
  type        = string
  description = "The name for the SNS topic to send notifications"
  default     = "zoom-recording-alerts"
}

variable "lambda_runtime" {
  type        = string
  description = "The runtime for the Lambda function"
  default     = "python3.11"
}

variable "sns_email" {
  type        = string
  description = "Email address for SNS topic subscription"
}

variable "zoom_webhook_secret_token" {
  type        = string
  description = "Zoom Webhook secret token"
}

variable "mongodb_api_endpoint" {
  type        = string
  description = "JR zoom server API endpoint"
}

variable "lambda_s3_bucket" {
  type        = string
  description = "The S3 bucket for the Lambda function"
}

variable "lambda_zip_path" {
  type        = string
  description = "Path to the Lambda zip file"
} 