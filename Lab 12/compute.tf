resource "aws_launch_template" "Linux" {
  name          = "Linux"
  image_id      = var.ubuntu
  instance_type = "t3.micro"
  key_name      = var.key_name
  vpc_security_group_ids = [ aws_security_group.SG.id ]
  user_data     = file("${path.module}/script.sh")

  placement {
    tenancy = "default"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ASG" {
  name                      = "ASG"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 10
  health_check_type         = "EC2"
  desired_capacity          = 1
  force_delete              = false
  vpc_zone_identifier = [ aws_subnet.Public_Subnet1.id, aws_subnet.Public_Subnet2.id ]

  launch_template {
    name = aws_launch_template.Linux.name
  }

  tag {
    key                 = "Name"
    value               = "ASG"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu_up" {
  autoscaling_group_name = aws_autoscaling_group.ASG.name
  name = "cpu_up_add_instance"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  policy_type = "SimpleScaling"
  cooldown = 60
}

resource "aws_autoscaling_policy" "cpu_down" {
  autoscaling_group_name = aws_autoscaling_group.ASG.name
  name = "cpu_down_remove_instance"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  policy_type = "SimpleScaling"
  cooldown = 60
}

resource "aws_cloudwatch_metric_alarm" "cpu_up" {
  alarm_name = "cpu_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 1
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  threshold = 60
  statistic = "Average"
  period = 10

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ASG.name
  }

  alarm_actions = [ data.aws_sns_topic.cpu.arn, aws_autoscaling_policy.cpu_up.arn ]
}

resource "aws_cloudwatch_metric_alarm" "cpu_down" {
  alarm_name = "cpu_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = 1
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  threshold = 40
  statistic = "Average"
  period = 10

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ASG.name
  }

  alarm_actions = [ data.aws_sns_topic.cpu.arn, aws_autoscaling_policy.cpu_down.arn ]
}
