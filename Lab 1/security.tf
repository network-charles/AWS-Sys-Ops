resource "aws_ebs_encryption_by_default" "ebs" {
  enabled = true
}

resource "aws_ebs_default_kms_key" "Cloud9" {
  key_arn = aws_kms_key.Cloud9.arn
}

resource "aws_kms_key" "Cloud9" {
  description             = "Cloud9"
  deletion_window_in_days = 7

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowAllActions",
        Effect    = "Allow",
        Principal = {
          AWS = "*",
        },
        Action    = "*",
        Resource  = "*",
      }
    ],
  })

  tags = {
    "Name" = "Cloud9"
  }
}
