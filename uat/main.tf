provider "aws" {
  region = "ap-southeast-2" 
}

module "zoom_to_s3" {
  source = "../module" 

  s3_bucket_name = var.s3_bucket_name
  sns_topic_name = var.sns_topic_name
  lambda_runtime = var.lambda_runtime
  sns_email = var.sns_email
  zoom_webhook_secret_token = var.zoom_webhook_secret_token
  mongodb_api_endpoint = var.mongodb_api_endpoint
  lambda_s3_bucket = var.lambda_s3_bucket
  lambda_zip_path = var.lambda_zip_path
  aws_lambda_layer_version_arn = var.aws_lambda_layer_version_arn
}
