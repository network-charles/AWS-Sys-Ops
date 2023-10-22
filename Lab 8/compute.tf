resource "aws_redshift_subnet_group" "Private" {
  name       = "private"
  subnet_ids = [aws_subnet.Private_Subnet1.id, aws_subnet.Private_Subnet2.id]

  tags = {
    Name = "My Redshift subnet group"
  }
}

resource "aws_redshift_cluster" "Cluster" {
  cluster_identifier = "redshift-cluster"
  database_name      = "mydb"
  master_username    = var.username
  master_password    = var.password
  node_type          = "ra3.xlplus"
  cluster_type       = "single-node"
  cluster_subnet_group_name = aws_redshift_subnet_group.Private.name
  availability_zone = "eu-west-2a"
  availability_zone_relocation_enabled = true
  encrypted = true
  kms_key_id = aws_kms_key.Redshift.arn
  iam_roles = [ aws_iam_role.Redshift_KMS_Role.arn ]
  skip_final_snapshot = true

  tags = {
    "Name" = "Cluster"
  }
}
