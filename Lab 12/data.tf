data "aws_instance" "one" {
  filter {
    name = "tag:Name"
    values = [ "ASG" ]
  }

  depends_on = [ aws_autoscaling_group.ASG ]
}

data "aws_sns_topic" "cpu" {
  name = "All_Topics"
}
