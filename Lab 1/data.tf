data "aws_iam_user" "iamadmin" {
  user_name = "iamadmin"
}

data "aws_instance" "cloud9_instance" {
  filter {
    name = "tag:aws:cloud9:environment"
    values = [
    aws_cloud9_environment_ec2.Cloud9.id]
  }
}

data "aws_iam_policy_document" "Cloud9" {
  version = "2012-10-17"
  
  statement {
    sid       = "EnableIAMRootUserPermissions"
    effect    = "Allow"
    
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::1234:root"]
    }
    
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowAccessForKeyAdministrators"
    effect = "Allow"
    
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::1234:user/iamadmin"]
    }
    
    actions   = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
    ]
    
    resources = ["*"]
  }

  statement {
    sid    = "AllowCloud9KMSActions"
    effect = "Allow"
    
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::1234:role/aws-service-role/cloud9.amazonaws.com/AWSServiceRoleForAWSCloud9"]
    }
    
    actions   = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    
    resources = ["*"]
  }

  statement {
    sid    = "AllowCloud9KeyUsage"
    effect = "Allow"
    
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::1234:role/aws-service-role/cloud9.amazonaws.com/AWSServiceRoleForAWSCloud9"]
    }
    
    actions   = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant",
    ]
    
    resources = ["*"]
    
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}

