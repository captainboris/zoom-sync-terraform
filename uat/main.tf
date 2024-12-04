provider "aws" {
  region = "ap-southeast-2" 
}

module "zoom_to_s3" {
  source = "../module" 

  s3_bucket_name = var.s3_bucket_name
  sns_topic_name = var.sns_topic_name
  lambda_runtime = var.lambda_runtime
  lambda_zip_path = var.lambda_zip_path
  sns_email = var.sns_email
}
