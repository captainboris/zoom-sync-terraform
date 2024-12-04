resource "aws_lambda_function" "zoom_upload_lambda" {
  filename         = var.lambda_zip_path
  function_name    = "zoomToS3Uploader"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "index.handler"
  runtime          = var.lambda_runtime

  environment {
    variables = {
      S3_BUCKET_NAME = var.s3_bucket_name
      SNS_TOPIC_ARN  = aws_sns_topic.zoom_sns_topic.arn
    }
  }
  
  source_code_hash = filebase64sha256(var.lambda_zip_path)

  depends_on = [
    aws_iam_role_policy_attachment.lambda_exec_policy_attach
  ]
}
