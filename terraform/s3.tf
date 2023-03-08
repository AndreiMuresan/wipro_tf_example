# === cost and usage reports bucket =============================================================================
resource "aws_s3_bucket" "cur_reports" {
  bucket = "${var.application}-cur-reports"
  tags   = local.tags

}

resource "aws_s3_bucket_public_access_block" "cur_reports_bucket_acl" {
  bucket                  = aws_s3_bucket.cur_reports.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "allow_access_from_cur" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["billingreports.amazonaws.com"]
    }

    actions       = [
      "s3:GetBucketAcl",
      "s3:GetBucketPolicy",
      "s3:PutObject"
    ]

    resources     = [ aws_s3_bucket.cur_reports.arn, "${aws_s3_bucket.cur_reports.arn}/*" ]

    condition {
      test        = "StringLike"
      variable    = "aws:SourceAccount"
      values      = [ "${data.aws_caller_identity.current.account_id}" ]
    }

    condition {
      test        = "StringLike"
      variable    = "aws:SourceArn"
      values      = [ "arn:aws:cur:us-east-1:${data.aws_caller_identity.current.account_id}:definition/*" ]
    }
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_cur" {
  bucket = aws_s3_bucket.cur_reports.id
  policy = data.aws_iam_policy_document.allow_access_from_cur.json

}

resource "aws_lambda_permission" "cur_reports_s3_trigger_lambda" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cur_crawler_initializer.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.cur_reports.arn
}

resource "aws_s3_bucket_notification" "cur_crawler_initializer_notification" {
  bucket                = aws_s3_bucket.cur_reports.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.cur_crawler_initializer.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".parquet"
  }

  depends_on            = [aws_lambda_permission.cur_reports_s3_trigger_lambda]
}

# === athena outputs bucket =============================================================================
resource "aws_s3_bucket" "athena_query_results" {
  bucket = "${var.application}-athena-query-results"
  tags   = local.tags
}

resource "aws_s3_bucket_public_access_block" "athena_query_results_bucket_acl" {
  bucket                  = aws_s3_bucket.athena_query_results.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_lambda_permission" "athena_query_results_s3_trigger_lambda" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.run_cli.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.athena_query_results.arn
}

resource "aws_s3_bucket_notification" "run_cli_notification" {
  bucket                = aws_s3_bucket.athena_query_results.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.run_cli.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }

  depends_on            = [ aws_s3_bucket.athena_query_results,
                            aws_lambda_function.run_cli,
                            aws_lambda_permission.athena_query_results_s3_trigger_lambda ]
}

# === carbon emission reports bucket =============================================================================
resource "aws_s3_bucket" "carbon_emission_reports" {
  bucket = "${var.application}-carbon-emission-reports"
  tags   = local.tags
}

resource "aws_s3_bucket_public_access_block" "carbon_emission_reports_bucket_acl" {
  bucket                  = aws_s3_bucket.carbon_emission_reports.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
