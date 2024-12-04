terraform {
  backend "s3" {
    bucket         = "jr-source-video-bucket"    # 您的 S3 存储桶名称
    key            = "uat/terraform.tfstate"        # 存储状态文件的路径
    region         = "ap-southeast-2"               # 存储桶所在的 AWS 区域
    # dynamodb_table = "terraform-lock-table"         # （可选）用于状态锁定的 DynamoDB 表
    encrypt        = true                           # 启用加密，确保状态文件的安全
  }
}
