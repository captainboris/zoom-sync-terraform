resource "aws_sns_topic" "zoom_sns_topic" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "sns_email_subscription" {
  topic_arn = aws_sns_topic.zoom_sns_topic.arn
  protocol  = "email"
  endpoint  = var.sns_email
}