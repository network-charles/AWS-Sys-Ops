resource "aws_security_group" "SG" {
  vpc_id      = aws_vpc.VPC.id
  description = "SG"

  ingress {
    from_port   = 0 # 1521 for Oracle
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "SG"
  }
}

resource "aws_kms_key" "Oracle" {
  description             = "Oracle"
  deletion_window_in_days = 7

  policy = data.aws_iam_policy_document.kms.json

  tags = {
    "Name" = "Oracle"
  }
}

resource "aws_iam_role" "Oracle_KMS_Role" {
  name = "OracleKMSRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "rds.amazonaws.com"
        }
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "kms.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
