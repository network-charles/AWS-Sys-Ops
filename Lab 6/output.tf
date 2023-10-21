output "Aurora_Primary_DB" {
  value = aws_rds_cluster.Writer.endpoint
}

output "Aurora_Replica1" {
  value = aws_rds_cluster_instance.Replica1.endpoint
}

output "Aurora_Replica2" {
  value = aws_rds_cluster_instance.Replica2.endpoint
}

output "Bastion1" {
  value = aws_instance.Bastion1.public_ip
}

output "Bastion2" {
  value = aws_instance.Bastion2.public_ip
}

output "Bastion3" {
  value = aws_instance.Bastion3.public_ip
}
