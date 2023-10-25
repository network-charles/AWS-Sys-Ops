output "Aurora_Primary_DB" {
  value = "mysql -h ${aws_rds_cluster.MySQL.endpoint} -u test -p"
}

output "Aurora_Writer" {
  value = "mysql -h ${aws_rds_cluster.Writer.endpoint} -u test -p"
}

output "Aurora_Replica1" {
  value = "mysql -h ${aws_rds_cluster.Replica1.endpoint} -u test -p"
}

output "Aurora_Replica2" {
  value = "mysql -h ${aws_rds_cluster.Replica2.endpoint} -u test -p"
}

output "Bastion1" {
  value = "ssh -i '${var.key_name}.pem' ubuntu@${aws_instance.Bastion1.public_ip}"
}

output "Bastion2" {
  value = "ssh -i '${var.key_name}.pem' ubuntu@${aws_instance.Bastion2.public_ip}"
}

output "Bastion3" {
  value = "ssh -i '${var.key_name}.pem' ubuntu@${aws_instance.Bastion3.public_ip}"
}
