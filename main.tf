terraform {
  backend "s3" {
    bucket = "sc2quotes-tfstate"
    key    = "terraform"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "eu-west-2"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "./src"
  output_path = var.lambda_zip
}

resource "aws_lambda_function" "lambda" {
  filename         = var.lambda_zip
  function_name    = "sc2quotes_lambda"
  role             = aws_iam_role.role.arn
  handler          = "lambda_handler.lambda_handler"
  runtime          = "python3.7"
  source_code_hash = filebase64sha256(var.lambda_zip)
  environment {
    variables = {
      CONSUMER_KEY    = var.CONSUMER_KEY
      CONSUMER_SECRET = var.CONSUMER_SECRET
      ACCESS_KEY      = var.ACCESS_KEY
      ACCESS_SECRET   = var.ACCESS_SECRET
    }
  }
}

# Schedule
resource "aws_cloudwatch_event_rule" "event_rule" {
  name                = "sc2quotes_cron"
  description         = "posting the quotes on the times"
  schedule_expression = "rate(2 hours)"
}

resource "aws_cloudwatch_event_target" "event_target" {
  rule = aws_cloudwatch_event_rule.event_rule.name
  arn  = aws_lambda_function.lambda.arn
}

resource "aws_lambda_permission" "event_permission" {
  statement_id  = "sc2quotes_permission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.event_rule.arn
}

resource "aws_iam_role" "role" {
  name = "sc2quotes_lambda_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }    
  ]
}
POLICY
}