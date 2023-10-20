output "Aurora_Primary_DB" {
  value = aws_rds_cluster.Write.endpoint
}

output "Aurora_Replica" {
  value = aws_rds_cluster_instance.Replica.endpoint
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
