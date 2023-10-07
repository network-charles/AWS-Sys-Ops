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
