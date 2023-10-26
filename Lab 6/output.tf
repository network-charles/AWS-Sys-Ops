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
