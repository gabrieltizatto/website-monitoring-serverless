resource "aws_lambda_function" "website_checker" {
  filename         = "${path.module}/files/lambda_function.zip"
  function_name    = var.function_name
  role             = aws_iam_role.monitoring_lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  environment {
    variables = {
      SENDER         = var.sender_email
      RECIPIENTS     = jsonencode(var.recipient_emails)
      WEBSITES       = jsonencode({ for w in var.websites : w.name => w.url })
      DYNAMODB_TABLE = aws_dynamodb_table.website_status.name
    }
  }
}

resource "aws_iam_role" "monitoring_lambda_role" {
  name = "website_monitoring_lambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "allow-ses"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = "ses:SendEmail"
          Resource = "*"
        },
        {
          Effect   = "Allow"
          Action   = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "*"
        },
        {
          Effect   = "Allow"
          Action   = [
            "dynamodb:GetItem",
            "dynamodb:PutItem"
          ]
          Resource = aws_dynamodb_table.website_status.arn
        }
      ]
    })
  }
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_event_rule" "this" {
  name        = "WebsiteMonitoring"
  description = "Fires every X minutes"
  schedule_expression = var.monitoring_rate
}

resource "aws_cloudwatch_event_target" "this" {
  rule      = aws_cloudwatch_event_rule.this.name
  target_id = "websiteChecker"
  arn       = aws_lambda_function.website_checker.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.website_checker.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}

resource "aws_dynamodb_table" "website_status" {
  name           = "website_status"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "url"
  attribute {
    name = "url"
    type = "S"
  }
}
