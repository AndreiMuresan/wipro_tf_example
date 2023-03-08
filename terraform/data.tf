data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "billing_data_bucket" {
  bucket     = aws_s3_bucket.cur_reports.bucket
  depends_on = [aws_s3_bucket.cur_reports]
}

# use this data structureif the cur reports bucket already exist
# data "aws_s3_bucket" "billing_data_bucket" {
#   bucket = "name_of_already_existing_bucket"
# }