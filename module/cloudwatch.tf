resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.zoom_upload_lambda.function_name}"
  retention_in_days = 90
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "LambdaErrorAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm if Lambda function errors exceed 1 in the evaluation period"
  dimensions = {
    FunctionName = aws_lambda_function.zoom_upload_lambda.function_name
  }
  alarm_actions = [aws_sns_topic.zoom_sns_topic.arn]
}
