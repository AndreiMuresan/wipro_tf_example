resource "aws_glue_catalog_database" "cost_and_usage_report" {
  name = "${var.application}-cost-and-usage-report"
}

resource "aws_glue_crawler" "cost_and_usage_report_crawler" {
  database_name = aws_glue_catalog_database.cost_and_usage_report.name
  name          = "${var.application}-cost-and-usage-report-crawler"
  description   = "A recurring crawler that keeps your CUR table in Athena up-to-date"
  role          = aws_iam_role.glue_crawler_role.arn
  tags          = local.tags

  schema_change_policy {
    delete_behavior = "DELETE_FROM_DATABASE"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  s3_target {
    path       = "s3://${data.aws_s3_bucket.billing_data_bucket.bucket}"
    exclusions = [ "**.json",
                   "**.yml",
                   "**.sql",
                   "**.csv",
                   "**.gz",
                   "**.zip" ]
  }
}
