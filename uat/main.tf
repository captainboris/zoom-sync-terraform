# main.tf 文件

provider "aws" {
  region = "ap-southeast-2"  # 根据需要填写您的 AWS 区域
}

module "zoom_to_s3" {
  source = "../module"  # 引用 module 文件夹中的所有资源文件

  # 传递所需的变量
  s3_bucket_name = var.s3_bucket_name
  sns_topic_name = var.sns_topic_name
  lambda_runtime = var.lambda_runtime
  lambda_zip_path = var.lambda_zip_path
  sns_email = var.sns_email
}
