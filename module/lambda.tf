resource "aws_lambda_function" "zoom_upload_lambda" {
  function_name    = "zoomToS3Uploader"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda.lambda_handler"
  runtime          = var.lambda_runtime
  s3_bucket        = var.lambda_s3_bucket
  s3_key           = var.lambda_zip_path
  layers           = [var.aws_lambda_layer_version_arn]

  environment {
    variables = {
      S3_BUCKET_NAME = var.s3_bucket_name
      SNS_TOPIC_ARN  = aws_sns_topic.zoom_sns_topic.arn
      ZOOM_WEBHOOK_SECRET_TOKEN = var.zoom_webhook_secret_token
      MONGODB_API_ENDPOINT = var.mongodb_api_endpoint
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_exec_policy_attach
  ]
}
