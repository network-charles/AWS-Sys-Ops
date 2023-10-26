output "RDS_Oracle" {
  value = "sqlplus ${var.username}/${var.password}@${aws_db_instance.Oracle.endpoint}/oracle"
}
