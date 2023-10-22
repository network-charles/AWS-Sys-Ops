data "aws_iam_policy_document" "kms" {
  version = "2012-10-17"

  statement {
    sid    = "EnableIAMRootAndSAMLUserPermissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }

    principals {
      type        = "Federated"
      identifiers = [var.FederatedUserARN]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }
}
