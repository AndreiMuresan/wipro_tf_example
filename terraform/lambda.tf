# =========== run_cli ==================================================================
# Let terraform create a .zip file on your local computer which contains the lambda code
data "archive_file" "run_cli_zip" {
	source_dir  = "${path.module}/lambda/run_cli"
	type 			  = "zip"

	// Create the .zip file
	output_path = "${path.module}/run_cli.zip"
}

# Create our lambda function in AWS and upload our .zip with our code to it
resource "aws_lambda_function" "run_cli" {
	# Function parameters we defined at the beginning
	function_name 	= "${var.application}-run-cli"
	handler 				= "lambda_function.lambda_handler"
	runtime 				= "python3.9"
	environment {
    variables 		= {
      S3BUCKET 		= "${aws_s3_bucket.carbon_emission_reports.bucket}"
      APPNAME 		= local.name
    }
  }

	# Upload the .zip file Terraform created to AWS
	filename 				 = "${path.module}/run_cli.zip"
	source_code_hash = data.archive_file.run_cli_zip.output_base64sha256

	# Connect our IAM resource to our lambda function in AWS
	role 					   = aws_iam_role.run_cli_lambda_role.arn
  tags             = local.tags
}

resource "aws_cloudwatch_log_group" "run_cli" {
  name              = "/aws/lambda/${var.application}-run-cli"
  retention_in_days = 30
  tags              = local.tags
}

# =========== scheduled_trigger =========================================================
# Let terraform create a .zip file on your local computer which contains the lambda code
data "archive_file" "scheduled_trigger_zip" {
	source_dir 	= "${path.module}/lambda/scheduled_trigger"
	type 			 	= "zip"

	// Create the .zip file
	output_path = "${path.module}/scheduled_trigger.zip"
}

# Create our lambda function in AWS and upload our .zip with our code to it
resource "aws_lambda_function" "scheduled_trigger" {
	# Function parameters we defined at the beginning
	function_name 	 = "${var.application}-scheduled-trigger"
	handler 				 = "lambda_function.lambda_handler"
	runtime 				 = "python3.9"
	environment {
    variables 	   = {
      S3BUCKET 		 = "${aws_s3_bucket.athena_query_results.bucket}"
      DATABASE 		 = "${aws_glue_catalog_database.cost_and_usage_report.name}"
      TABLE 			 = "${var.application}-cur"
    }
  }

	# Upload the .zip file Terraform created to AWS
	filename 				 = "${path.module}/scheduled_trigger.zip"
	source_code_hash = data.archive_file.scheduled_trigger_zip.output_base64sha256

	# Connect our IAM resource to our lambda function in AWS
	role 						 = aws_iam_role.scheduled_trigger_lambda_role.arn
	tags             = local.tags
}

resource "aws_cloudwatch_log_group" "scheduled_trigger" {
  name              = "/aws/lambda/${var.application}-scheduled-trigger"
  retention_in_days = 30
  tags              = local.tags
}

# =========== cur_crawler_initializer ====================================================
# Let terraform create a .zip file on your local computer which contains the lambda code
data "archive_file" "cur_crawler_initializer_zip" {
	source_dir 	= "${path.module}/lambda/cur_crawler_initializer"
	type 				= "zip"

	// Create the .zip file
	output_path = "${path.module}/cur_crawler_initializer.zip"
}

# Create our lambda function in AWS and upload our .zip with our code to it
resource "aws_lambda_function" "cur_crawler_initializer" {
	# Function parameters we defined at the beginning
	function_name 	 = "${var.application}-cur-crawler-initializer"
	handler 				 = "index.handler"
	runtime 				 = "nodejs16.x"
	environment {
    variables 	   = {
      CRAWLERNAME  = "${aws_glue_crawler.cost_and_usage_report_crawler.name}"
    }
  }

	# Upload the .zip file Terraform created to AWS
	filename 				 = "${path.module}/cur_crawler_initializer.zip"
	source_code_hash = data.archive_file.cur_crawler_initializer_zip.output_base64sha256

	# Connect our IAM resource to our lambda function in AWS
	role 					   = aws_iam_role.cur_crawler_initializer_lambda_role.arn
	tags             = local.tags
}

resource "aws_cloudwatch_log_group" "cur_crawler_initializer" {
  name              = "/aws/lambda/${var.application}-cur-crawler-initializer"
  retention_in_days = 30
  tags              = local.tags
}
