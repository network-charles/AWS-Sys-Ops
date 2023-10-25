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

  depends_on = [aws_elasticache_replication_group.Primary]
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

  depends_on = [aws_elasticache_replication_group.Primary]
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

  depends_on = [aws_elasticache_replication_group.Primary]
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
    key                 = "Name"
    value               = "ASG"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_elasticache_replication_group.Primary]
}

resource "aws_elasticache_subnet_group" "Redis" {
  name       = "redis-cache-subnet"
  subnet_ids = [aws_subnet.Private_Subnet1.id, aws_subnet.Private_Subnet2.id]
}

resource "aws_elasticache_replication_group" "Primary" {
  apply_immediately          = true
  at_rest_encryption_enabled = true
  automatic_failover_enabled = true
  description                = "primary"
  engine_version             = "7.0"
  engine                     = "redis"
  kms_key_id                 = aws_kms_key.Redis.arn
  multi_az_enabled           = true
  node_type                  = "cache.t3.micro"
  num_node_groups            = 2 # two shards
  port                       = 6379
  parameter_group_name       = "default.redis7.cluster.on" # "on" specifies that cluster is enabled
  replicas_per_node_group    = 1 # One Primary and Replica
  replication_group_id       = "Primary"
  security_group_ids         = [aws_security_group.SG.id]
  subnet_group_name          = aws_elasticache_subnet_group.Redis.name

  tags = {
    "Name" = "Primary"
  }
}
