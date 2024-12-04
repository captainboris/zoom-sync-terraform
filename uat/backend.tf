terraform {
  backend "s3" {
    bucket         = "jr-source-video-bucket" 
    key            = "uat/terraform.tfstate"      
    region         = "ap-southeast-2"              
    # dynamodb_table = "terraform-lock-table"      
    encrypt        = true                          
  }
}
