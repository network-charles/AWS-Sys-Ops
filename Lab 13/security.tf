
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
  name = "EC2-Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    "Name" = "EC2_Role"
  }
}

resource "aws_iam_role_policy_attachment" "AdministratorAccess" {
  policy_arn = data.aws_iam_policy.AdministratorAccess.arn
  role       = aws_iam_role.EC2_Role.name
}

resource "aws_iam_instance_profile" "SSMInstanceProfile" {
  name = "SSMInstanceProfile"
  role = aws_iam_role.EC2_Role.name
}

resource "aws_ssm_maintenance_window" "window" {
  name     = "maintenance-window-application"
  schedule = "rate(4 minutes)"
  duration = 3
  cutoff   = 1
}

resource "aws_ssm_maintenance_window_target" "target" {
  window_id     = aws_ssm_maintenance_window.window.id
  name          = "maintenance-window-target"
  description   = "This is a maintenance window target"
  resource_type = "INSTANCE"

  targets {
    key    = "InstanceIds"
    values = [aws_instance.Instance.id]
  }
}

resource "aws_ssm_maintenance_window_task" "Patch_EC2" {
  max_concurrency  = 2
  max_errors       = 1
  priority         = 1
  task_arn         = "AWS-PatchInstanceWithRollback"
  task_type        = "AUTOMATION"
  window_id        = aws_ssm_maintenance_window.window.id
  service_role_arn = aws_iam_role.EC2_Role.arn

  targets {
    key    = "InstanceIds"
    values = [aws_instance.Instance.id]
  }

  task_invocation_parameters {
    automation_parameters {
      document_version = "$LATEST"

      parameter {
        name   = "InstanceId"
        values = [aws_instance.Instance.id]
      }
    }
  }
}

resource "aws_ssm_maintenance_window_task" "Stop_EC2" {
  max_concurrency  = 2
  max_errors       = 1
  priority         = 2
  task_arn         = "AWS-StopEC2Instance"
  task_type        = "AUTOMATION"
  window_id        = aws_ssm_maintenance_window.window.id
  service_role_arn = aws_iam_role.EC2_Role.arn

  targets {
    key    = "InstanceIds"
    values = [aws_instance.Instance.id]
  }

  task_invocation_parameters {
    automation_parameters {
      document_version = "$LATEST"

      parameter {
        name   = "InstanceId"
        values = [aws_instance.Instance.id]
      }
    }
  }
}

resource "aws_ssm_maintenance_window_task" "Lambda" {
  max_concurrency  = 1
  max_errors       = 1
  priority         = 3
  task_arn         = aws_lambda_function.ssm_lambda.arn
  task_type        = "LAMBDA"
  window_id        = aws_ssm_maintenance_window.window.id
  service_role_arn = aws_iam_role.EC2_Role.arn

  targets {
    key    = "InstanceIds"
    values = [aws_instance.Instance.id]
  }

  task_invocation_parameters {
    lambda_parameters {
      payload = jsonencode({ "InstanceId": aws_instance.Instance.id })
    }
  }
}

resource "aws_ssm_maintenance_window_task" "Start_EC2" {
  max_concurrency  = 2
  max_errors       = 1
  priority         = 4
  task_arn         = "AWS-StartEC2Instance"
  task_type        = "AUTOMATION"
  window_id        = aws_ssm_maintenance_window.window.id
  service_role_arn = aws_iam_role.EC2_Role.arn

  targets {
    key    = "InstanceIds"
    values = [aws_instance.Instance.id]
  }

  task_invocation_parameters {
    automation_parameters {
      document_version = "$LATEST"

      parameter {
        name   = "InstanceId"
        values = [aws_instance.Instance.id]
      }
    }
  }
}
