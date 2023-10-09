# aws ssm start-session --target i-09711f32a214339dd

output "EC2_ID" {
  value = aws_instance.Instance.id
}
