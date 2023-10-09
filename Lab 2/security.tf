resource "aws_security_group" "SG" {
  vpc_id      = aws_vpc.VPC.id
  description = "SG"

  ingress {
    from_port   = 0
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

# Create an IAM role for the EC2 instance to allow AWS SSM access.
resource "aws_iam_role" "EC2_Role" {
  name               = "EC2-Role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
      "Effect": "Allow",
      "Principal": {
          "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    "Name" = "EC2_Role"
  }
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
  role       = aws_iam_role.EC2_Role.name
}

resource "aws_iam_instance_profile" "SSMInstanceProfile" {
  name = "SSMInstanceProfile"
  role = aws_iam_role.EC2_Role.name
}
