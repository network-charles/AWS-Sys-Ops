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

  depends_on = [aws_elasticache_replication_group.Primary]
}

resource "aws_autoscaling_group" "Bastion" {
  name                      = "Bastion"
  max_size                  = 2
  min_size                  = 2
  health_check_grace_period = 30
  health_check_type         = "EC2"
  desired_capacity          = 2
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
