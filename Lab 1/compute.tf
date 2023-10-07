resource "aws_cloud9_environment_ec2" "Cloud9" {
  name = "Cloud9"
  instance_type = "t3.small"
  automatic_stop_time_minutes = "30"
  connection_type = "CONNECT_SSH"
  image_id = "amazonlinux-2-x86_64"
  subnet_id = aws_subnet.public_subnet.id
  owner_arn = data.aws_iam_user.iamadmin.arn
  tags = {
    "name" = "Cloud9"
  }

  depends_on = [ aws_ebs_encryption_by_default.ebs, aws_kms_key.Cloud9, aws_ebs_default_kms_key.Cloud9 ]
}
