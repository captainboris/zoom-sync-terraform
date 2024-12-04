resource "aws_api_gateway_rest_api" "zoom_api" {
  name        = "ZoomWebhookAPI"
  description = "API Gateway for Zoom Recording Webhook"
}

resource "aws_api_gateway_resource" "zoom_resource" {
  rest_api_id = aws_api_gateway_rest_api.zoom_api.id
  parent_id   = aws_api_gateway_rest_api.zoom_api.root_resource_id
  path_part   = "zoom"
}

resource "aws_api_gateway_method" "zoom_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.zoom_api.id
  resource_id   = aws_api_gateway_resource.zoom_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "zoom_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.zoom_api.id
  resource_id             = aws_api_gateway_resource.zoom_resource.id
  http_method             = aws_api_gateway_method.zoom_post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.zoom_upload_lambda.invoke_arn
}

resource "aws_lambda_permission" "apigw_invoke_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.zoom_upload_lambda.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_api_gateway_deployment" "zoom_api_deployment" {
  depends_on = [aws_api_gateway_integration.zoom_lambda_integration]  # 确保 API 与 Lambda 集成后再进行部署
  rest_api_id = aws_api_gateway_rest_api.zoom_api.id
}

resource "aws_api_gateway_stage" "zoom_api_stage" {
  rest_api_id   = aws_api_gateway_rest_api.zoom_api.id
  deployment_id = aws_api_gateway_deployment.zoom_api_deployment.id
  stage_name    = "uat"
}
