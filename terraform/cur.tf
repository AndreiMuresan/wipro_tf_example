resource "aws_cur_report_definition" "cur_report_definition" {
  count                      = var.environment == "qa" ? 0 : 1
  provider                   = aws.useast1
  report_name                = "${var.application}-cur"
  time_unit                  = "HOURLY"
  format                     = "Parquet"
  compression                = "Parquet"
  additional_schema_elements = ["RESOURCES"]
  s3_bucket                  = aws_s3_bucket.cur_reports.bucket
  s3_region                  = var.default_region
  s3_prefix                  = var.application
  additional_artifacts       = ["ATHENA"]
  report_versioning          = "OVERWRITE_REPORT"

  depends_on                 = [aws_s3_bucket.cur_reports]
}