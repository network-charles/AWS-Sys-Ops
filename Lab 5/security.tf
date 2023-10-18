resource "aws_config_configuration_recorder" "config_recorder" {
  name     = "config_recorder"
  role_arn = aws_iam_role.Config_Role.arn

  recording_group {
    all_supported = false
    recording_strategy {
      use_only = "INCLUSION_BY_RESOURCE_TYPES"
    }
    resource_types = [ "AWS::EC2::Subnet" ]
  }
}

resource "aws_config_configuration_recorder_status" "enable" {
  name       = aws_config_configuration_recorder.config_recorder.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.S3]
}

resource "aws_config_delivery_channel" "S3" {
  name           = "config-logs"
  s3_bucket_name = data.aws_s3_bucket.S3.id

  depends_on = [ aws_config_configuration_recorder.config_recorder ]
}

resource "aws_config_config_rule" "Subnet" {
  name = "Subnet"

  source {
    owner             = "AWS"
    source_identifier = "SUBNET_AUTO_ASSIGN_PUBLIC_IP_DISABLED"
  }

  scope {
    compliance_resource_id = aws_subnet.Private_Subnet.id
    compliance_resource_types = [ "AWS::EC2::Subnet" ]
  }
}

resource "aws_config_remediation_configuration" "Subnet" {
  config_rule_name = aws_config_config_rule.Subnet.name
  resource_type    = "AWS::EC2::Subnet"
  target_type      = "SSM_DOCUMENT"
  target_id        = "AWSConfigRemediation-DisableSubnetAutoAssignPublicIP"
  automatic = true
  maximum_automatic_attempts = 3
  retry_attempt_seconds      = 60

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.Config_Role.arn
  }
  parameter {
    name           = "SubnetId"
    # Defaults to all subnet in the VPC
    resource_value = "RESOURCE_ID"
  }

  execution_controls {
    ssm_controls {
      concurrent_execution_rate_percentage = 25
      error_percentage                     = 20
    }
  }
}

# Create an IAM role for the EC2 instance to allow AWS SSM access.
resource "aws_iam_role" "Config_Role" {
  name = "Config_Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    "Name" = "Config_Role"
  }
}

resource "aws_iam_policy" "custom_policy" {
  name        = "CustomPolicy"
  description = "Custom IAM policy for SSM, Config, and EC2 actions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ssm:StartAutomationExecution",
          "ssm:GetAutomationExecution",
          "ec2:DescribeSubnets",
          "ec2:ModifySubnetAttribute",
          "s3:*"
        ],
        Effect   = "Allow",
        Resource = "*",
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "custom_policy" {
  policy_arn = aws_iam_policy.custom_policy.arn
  role       = aws_iam_role.Config_Role.name
}

resource "aws_iam_role_policy_attachment" "AWS_ConfigRole" {
  policy_arn = data.aws_iam_policy.AWS_ConfigRole.arn
  role       = aws_iam_role.Config_Role.name
}
