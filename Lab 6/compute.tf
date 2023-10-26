resource "aws_launch_template" "Linux" {
  name          = "Linux"
  image_id      = var.ubuntu
  instance_type = "t3.micro"
  key_name      = var.key_name
  vpc_security_group_ids = [ aws_security_group.SG.id ]

  placement {
    tenancy = "default"
  }

  lifecycle {
    create_before_destroy = true
  }

  user_data = filebase64("${path.module}/script.sh")

  depends_on = [aws_rds_cluste.MySQL]
}

resource "aws_autoscaling_group" "Bastion" {
  name                      = "Bastion"
  max_size                  = 3
  min_size                  = 3
  health_check_grace_period = 30
  health_check_type         = "EC2"
  desired_capacity          = 3
  force_delete              = false
  vpc_zone_identifier = [ aws_subnet.Public_Subnet1.id, aws_subnet.Public_Subnet2.id ]

  launch_template {
    name = aws_launch_template.Linux.name
  }

  tag {
    key                 = "Name"
    value               = "Bastion"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_rds_cluste.MySQL]
}

resource "aws_db_subnet_group" "Private" {
  name       = "private"
  subnet_ids = [aws_subnet.Private_Subnet1.id, aws_subnet.Private_Subnet2.id, aws_subnet.Private_Subnet3.id]

  tags = {
    Name = "My DB subnet group"
  }
}
 
resource "aws_rds_cluster" "MySQL" {
  cluster_identifier     = "aurora-mysql"
  engine                 = "aurora-mysql"
  engine_version         = "8.0.mysql_aurora.3.04.0"
  engine_mode            = "provisioned"
  database_name          = "mydb"
  master_username        = "test"
  master_password        = "must_be_eight_characters"
  kms_key_id             = aws_kms_key.mysql_aurora.arn
  storage_encrypted      = true
  vpc_security_group_ids = [aws_security_group.SG.id]
  availability_zones = [ "eu-west-2a", "eu-west-2b", "eu-west-2c" ]
  db_subnet_group_name = aws_db_subnet_group.Private.name
  source_region = "eu-west-2"
  iam_roles = [ aws_iam_role.aurora_kms_role.arn ]

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }

  skip_final_snapshot = true

  tags = {
    "Name" = "MySQL"
  }
}

resource "aws_rds_cluster_instance" "Writer" {
  cluster_identifier = aws_rds_cluster.MySQL.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.MySQL.engine
  engine_version     = aws_rds_cluster.MySQL.engine_version
  db_subnet_group_name = aws_db_subnet_group.Private.name
}

resource "aws_rds_cluster_instance" "Replica1" {
  cluster_identifier = aws_rds_cluster.MySQL.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.MySQL.engine
  engine_version     = aws_rds_cluster.MySQL.engine_version
  db_subnet_group_name = aws_db_subnet_group.Private.name
}

resource "aws_rds_cluster_instance" "Replica2" {
  cluster_identifier = aws_rds_cluster.MySQL.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.MySQL.engine
  engine_version     = aws_rds_cluster.MySQL.engine_version
  db_subnet_group_name = aws_db_subnet_group.Private.name
}
