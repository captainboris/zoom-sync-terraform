# terraform {
#   backend "s3" {
#     bucket         = "jr-zoom-sync-remote-state-bucket"
#     key            = "uat/terraform.tfstate"
#     region         = "ap-southeast-2"
#     dynamodb_table = "jr-zoom-sync-remote-statelock-table"
#     encrypt        = true
#   }
# }
