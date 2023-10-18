data "aws_iam_policy" "AWS_ConfigRole" {
  name = "AWS_ConfigRole"
}

data "aws_s3_bucket" "S3" {
  bucket = "bucet-name"
}
