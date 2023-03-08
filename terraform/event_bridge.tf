resource "aws_cloudwatch_event_rule" "run_athena_query_cron" {
  count               = var.environment == "qa" ? 0 : 1
  name                = "${var.application}-run-athena-query-cron"
  schedule_expression = "rate(2 hours)"
  tags                = local.tags
}

resource "aws_cloudwatch_event_target" "scheduled_trigger_lambda_target" {
  count = var.environment == "qa" ? 0 : 1
  arn   = aws_lambda_function.scheduled_trigger.arn
  rule  = aws_cloudwatch_event_rule.run_athena_query_cron[0].name
#  rule = aws_cloudwatch_event_rule.run_athena_query_cron.name
}

resource "aws_lambda_permission" "eventbridge_trigger_lambda" {
  count         = var.environment == "qa" ? 0 : 1
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.scheduled_trigger.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.run_athena_query_cron[0].arn
#  source_arn    = aws_cloudwatch_event_rule.run_athena_query_cron.arn
}
