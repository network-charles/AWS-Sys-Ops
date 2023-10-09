resource "aws_instance" "Instance" {
  ami             = "ami-0b2287cff5d6be10f" #Amaon Linux 2
  instance_type   = "t3.micro"
  tenancy         = "default"
  security_groups = [aws_security_group.SG.id]
  subnet_id       = aws_subnet.private_subnet.id

  iam_instance_profile = aws_iam_instance_profile.SSMInstanceProfile.name

  tags = {
    "Name" = "Instance"
  }
}
