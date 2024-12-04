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
  default     = "python3.8"
}

variable "lambda_zip_path" {
  type        = string
  description = "Path to the Lambda zip file"
}

variable "sns_email" {
  type        = string
  description = "Email address for SNS topic subscription"
}
