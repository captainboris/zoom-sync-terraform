s3_bucket_name = "jr-source-video-bucket"
sns_topic_name = "zoom-recording-alerts"
lambda_runtime = "python3.11"
sns_email = "captainboris246281@gmail.com"
zoom_webhook_secret_token = "123456789"
mongodb_api_endpoint = "https://api.zoom.us/v2/meetings/123456789/recordings"
lambda_s3_bucket = "jr-lambda-zip-bucket"                                                    # remember to create one before provisioning
lambda_zip_path = "lambda_function_V01.zip"
aws_lambda_layer_version_arn = "arn:aws:lambda:ap-southeast-2:123456789:layer:python-3-11:1" # remember to create one before provisioning
