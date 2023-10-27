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

  depends_on = [aws_elasticache_cluster.Memcached]
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

  depends_on = [aws_elasticache_cluster.Memcached]
}

resource "aws_elasticache_subnet_group" "Memcached" {
  name       = "Memcached-cache-subnet"
  subnet_ids = [aws_subnet.Private_Subnet1.id, aws_subnet.Private_Subnet2.id]
}

resource "aws_elasticache_cluster" "Memcached" {
  apply_immediately            = true
  az_mode                      = "cross-az"
  cluster_id                   = "memcached-cluster"
  engine_version               = "1.6.17"
  engine                       = "memcached"
  node_type                    = "cache.r6g.large"
  num_cache_nodes              = 2 # two shards
  port                         = 11211
  parameter_group_name         = "default.memcached1.6"
  preferred_availability_zones = ["eu-west-2a", "eu-west-2b"]
  security_group_ids           = [aws_security_group.SG.id]
  subnet_group_name            = aws_elasticache_subnet_group.Memcached.name
  transit_encryption_enabled   = true

  tags = {
    "Name" = "Memcached"
  }
}
