resource "aws_security_group" "SG" {
  vpc_id      = aws_vpc.VPC.id
  description = "SG"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6379 # redis default port
    to_port     = 6379
    protocol    = "tcp"
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

resource "aws_kms_key" "Redis" {
  description             = "Redis"
  deletion_window_in_days = 7

  policy = data.aws_iam_policy_document.kms.json

  tags = {
    "Name" = "Redis"
  }
}

resource "aws_iam_role" "Redis_KMS_Role" {
  name = "RedisKMSRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "elasticache.amazonaws.com"
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
