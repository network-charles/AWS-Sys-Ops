output "Redis_Endpoint" {
  value = "redis-cli -h ${aws_elasticache_replication_group.Primary.configuration_endpoint_address} -p 6379"
}

output "Bastion1" {
  value = "ssh -i '${var.key_name}.pem' ubuntu@${aws_instance.Bastion1.public_ip}"
}

/*
Key-Value Store:
SET username:1 "john_doe"
GET username:1

# determine the hash slot number associated with a key
CLUSTER KEYSLOT username:1
*/
