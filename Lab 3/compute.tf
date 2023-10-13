resource "aws_s3_bucket" "event_bridge" {
  bucket = "event-bridge-test-bucket-charles-uneze"

  tags = {
    "Name" = "event_bridge"
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.event_bridge.id
  eventbridge = true
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.event_bridge.bucket
  key    = "event"
  source = "./event.txt"

  etag = filemd5("./event.txt")

  depends_on = [ 
   
  ]
}

resource "aws_cloudwatch_event_rule" "s3" {
  name        = "object-notification"
  is_enabled = true

  event_pattern = jsonencode({
    source = ["aws.s3"],
    detail-type = ["Object Created", "Object Deleted"]
  })
}

resource "aws_cloudwatch_event_target" "sns" {
  arn = data.aws_sns_topic.All_Topics.arn
  rule = aws_cloudwatch_event_rule.s3.id
}

resource "aws_sns_topic_policy" "default" {
  arn    = data.aws_sns_topic.All_Topics.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [data.aws_sns_topic.All_Topics.arn]
  }
}
