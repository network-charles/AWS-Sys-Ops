resource "aws_instance" "Bastion1" {
  ami             = var.ubuntu
  instance_type   = "t3.micro"
  tenancy         = "default"
  security_groups = [aws_security_group.SG.id]
  subnet_id       = aws_subnet.Public_Subnet1.id
  user_data       = file("${path.module}/script.sh")
  key_name        = var.key_name

  tags = {
    "Name" = "Bastion1"
  }

  depends_on = [aws_db_instance.Oracle]
}

resource "aws_instance" "Bastion2" {
  ami             = var.ubuntu
  instance_type   = "t3.micro"
  tenancy         = "default"
  security_groups = [aws_security_group.SG.id]
  subnet_id       = aws_subnet.Public_Subnet2.id
  user_data       = file("${path.module}/script.sh")
  key_name        = var.key_name

  tags = {
    "Name" = "Bastion2"
  }

  depends_on = [aws_db_instance.Oracle]
}

resource "aws_launch_configuration" "Linux" {
  name          = "Linux"
  image_id      = var.ubuntu
  instance_type = "t3.micro"
  user_data     = file("${path.module}/script.sh")
  key_name      = var.key_name

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_db_instance.Oracle]
}

resource "aws_autoscaling_group" "Bastion" {
  name                      = "Bastion"
  max_size                  = 1
  min_size                  = 0
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 1
  force_delete              = false
  availability_zones        = ["eu-west-2a", "eu-west-2b"]
  launch_configuration      = aws_launch_configuration.Linux.name

  tag {
    key                 = "ASG"
    value               = "Bastion"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_db_instance.Oracle]
}

resource "aws_db_subnet_group" "Private" {
  name       = "private"
  subnet_ids = [aws_subnet.Private_Subnet1.id, aws_subnet.Private_Subnet2.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "Oracle" {
  allocated_storage       = 20
  availability_zone       = "eu-west-2a"
  backup_retention_period = 1
  db_subnet_group_name    = aws_db_subnet_group.Private.name
  db_name                 = "ORACLE"
  engine                  = "oracle-ee"
  engine_version          = "19.0.0.0.ru-2023-07.rur-2023-07.r1"
  identifier              = "oracle"
  instance_class          = "db.t3.medium"
  kms_key_id              = aws_kms_key.Oracle.arn
  license_model           = "bring-your-own-license"
  password                = var.password
  skip_final_snapshot     = true
  storage_encrypted       = true
  username                = var.username
  vpc_security_group_ids  = [aws_security_group.SG.id]

  tags = {
    "Name" = "Oracle"
  }
}

resource "aws_db_instance" "Replica" {
  availability_zone        = "eu-west-2b"
  backup_retention_period = 1
  engine_version           = "19.0.0.0.ru-2023-07.rur-2023-07.r1"
  identifier               = "oracle-replica"
  instance_class           = "db.t3.medium"
  kms_key_id               = aws_kms_key.Oracle.arn
  license_model            = "bring-your-own-license"
  replica_mode             = "open-read-only"
  replicate_source_db      = aws_db_instance.Oracle.identifier
  skip_final_snapshot      = true
  storage_encrypted        = true
  vpc_security_group_ids   = [aws_security_group.SG.id]

  tags = {
    "Name" = "Replica"
  }
}
