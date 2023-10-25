output "RDS_Oracle" {
  value = "sqlplus ${var.username}/${var.password}@${aws_db_instance.Oracle.endpoint}/oracle"
}

output "Bastion1" {
  value = "ssh -i \'${var.key_name}.pem\' ubuntu@${aws_instance.Bastion1.public_ip}"
}

output "Bastion2" {
  value = "ssh -i \'${var.key_name}.pem\' ubuntu@${aws_instance.Bastion2.public_ip}"
}

