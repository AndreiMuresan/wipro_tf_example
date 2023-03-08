# policy documents
data "aws_iam_policy_document" "assume_role_ec2_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "assume_role_lambda_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "assume_role_glue_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ccf_cli_ec2" {
  statement {
    actions   = ["s3:*"]
    effect    = "Allow"
    resources = [ aws_s3_bucket.athena_query_results.arn, "${aws_s3_bucket.athena_query_results.arn}/*"]
  }
  statement {
    actions   = ["s3:*"]
    effect    = "Allow"
    resources = [aws_s3_bucket.carbon_emission_reports.arn, "${aws_s3_bucket.carbon_emission_reports.arn}/*"]
  }
  statement {
    actions   = ["codecommit:GitPull"]
    effect    = "Allow"
    resources = ["arn:aws:codecommit:sanitized_region:sanitized_accountId:cloud-carbon-footprint"]
  }
}

data "aws_iam_policy_document" "lambda_run_cli" {
  statement {
    actions   = ["ssm:SendCommand"]
    effect    = "Allow"
    resources = ["arn:aws:ssm:*:*:document/*"]
  }
  statement {
    actions   = ["ssm:SendCommand"]
    effect    = "Allow"
    resources = ["arn:aws:ec2:*:*:instance/*"]
  }
  statement {
    actions   = ["ec2:DescribeInstanceStatus"]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions   = [ "logs:CreateLogStream",
                  "logs:PutLogEvents" ]
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]
  }
}

data "aws_iam_policy_document" "lambda_scheduled_trigger" {
  statement {
    actions   = [ "s3:GetBucketLocation",
                  "s3:GetObject",
                  "s3:ListBucket" ]
    effect    = "Allow"
    resources = [data.aws_s3_bucket.billing_data_bucket.arn, "${data.aws_s3_bucket.billing_data_bucket.arn}/*"]
  }
  statement {
    actions   = [ "s3:GetBucketLocation",
                  "s3:GetObject",
                  "s3:ListBucket",
                  "s3:ListBucketMultipartUploads",
                  "s3:ListMultipartUploadParts",
                  "s3:AbortMultipartUpload",
                  "s3:PutObject" ]
    effect    = "Allow"
    resources = [aws_s3_bucket.athena_query_results.arn, "${aws_s3_bucket.athena_query_results.arn}/*"]
  }
  statement {
    actions   = [ "glue:GetDatabase",
                  "glue:GetTable",
                  "glue:GetPartitions" ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions   = [ "athena:StartQueryExecution",
                  "athena:GetQueryExecution",
                  "athena:GetQueryResults",
                  "athena:GetWorkGroup" ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions   = [ "ce:GetRightsizingRecommendation" ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions   = [ "logs:CreateLogStream",
                  "logs:PutLogEvents" ]
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]
  }
}

data "aws_iam_policy_document" "glue_crawler" {
  statement {
    actions   = [ "logs:CreateLogGroup",
                  "logs:CreateLogStream",
                  "logs:PutLogEvents" ]
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]
  }
  statement {
    actions   = [ "glue:UpdateDatabase",
                  "glue:UpdatePartition",
                  "glue:CreateTable",
                  "glue:UpdateTable",
                  "glue:ImportCatalogToGlue" ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions   = [ "s3:GetObject",
                  "s3:PutObject" ]
    effect    = "Allow"
    resources = [data.aws_s3_bucket.billing_data_bucket.arn, "${data.aws_s3_bucket.billing_data_bucket.arn}/*"]
  }
  statement {
    actions   = [ "kms:Decrypt" ]
    effect    = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "crawler_executor" {
  statement {
    actions   = [ "logs:CreateLogStream",
                  "logs:PutLogEvents" ]
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]
  }
  statement {
    actions   = ["glue:StartCrawler"]
    effect    = "Allow"
    resources = ["*"]
  }
}

# policies
resource "aws_iam_policy" "ccf_cli_ec2_policy" {
  name   = "${var.application}-ccf-cli-ec2-policy"
  policy = data.aws_iam_policy_document.ccf_cli_ec2.json
  tags   = local.tags
}

resource "aws_iam_policy" "lambda_run_cli_policy" {
  name   = "${var.application}-lambda-run_cli-policy"
  policy = data.aws_iam_policy_document.lambda_run_cli.json
  tags   = local.tags
}

resource "aws_iam_policy" "lambda_scheduled_trigger_policy" {
  name   = "${var.application}-lambda-scheduled-trigger-policy"
  policy = data.aws_iam_policy_document.lambda_scheduled_trigger.json
  tags   = local.tags
}

resource "aws_iam_policy" "glue_crawler_policy" {
  name   = "${var.application}-glue-crawler-policy"
  policy = data.aws_iam_policy_document.glue_crawler.json
  tags   = local.tags
}

resource "aws_iam_policy" "crawler_executor_policy" {
  name   = "${var.application}-crawler-executor-policy"
  policy = data.aws_iam_policy_document.crawler_executor.json
  tags   = local.tags
}

# policy attachments
resource "aws_iam_role_policy_attachment" "ccf_cli_ec2" {
  policy_arn = aws_iam_policy.ccf_cli_ec2_policy.arn
  role       = aws_iam_role.ccf_cli_ec2_role.name
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ccf_cli_ec2_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_run_cli" {
  policy_arn = aws_iam_policy.lambda_run_cli_policy.arn
  role       = aws_iam_role.run_cli_lambda_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_scheduled_trigger" {
  policy_arn = aws_iam_policy.lambda_scheduled_trigger_policy.arn
  role       = aws_iam_role.scheduled_trigger_lambda_role.name
}

resource "aws_iam_role_policy_attachment" "glue_crawler_policy" {
  policy_arn = aws_iam_policy.glue_crawler_policy.arn
  role       = aws_iam_role.glue_crawler_role.name
}

# todo: review the policy below since it's too permissive
resource "aws_iam_role_policy_attachment" "glue_service_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  role       = aws_iam_role.glue_crawler_role.name
}

resource "aws_iam_role_policy_attachment" "crawler_executor_policy" {
  policy_arn = aws_iam_policy.crawler_executor_policy.arn
  role       = aws_iam_role.cur_crawler_initializer_lambda_role.name
}

# role
resource "aws_iam_role" "ccf_cli_ec2_role" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2_policy.json
  name               = "${var.application}-ccf-cli-ec2-role"
  tags               = local.tags
}

resource "aws_iam_role" "run_cli_lambda_role" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda_policy.json
  name               = "${var.application}-run-cli-lambda-role"
  tags               = local.tags
}

resource "aws_iam_role" "scheduled_trigger_lambda_role" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda_policy.json
  name               = "${var.application}-scheduled-trigger-lambda-role"
  tags               = local.tags
}

resource "aws_iam_role" "glue_crawler_role" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_glue_policy.json
  name               = "${var.application}-glue-crawler-role"
  tags               = local.tags
}

resource "aws_iam_role" "cur_crawler_initializer_lambda_role" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_lambda_policy.json
  name               = "${var.application}-cur-crawler-initializer-lambda-role"
  tags               = local.tags
}
