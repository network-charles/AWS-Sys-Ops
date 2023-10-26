output "Redis_Endpoint" {
  value = "redis-cli -h ${aws_elasticache_replication_group.Primary.configuration_endpoint_address} -p 6379"
}

/*
Key-Value Store:
SET username:1 "john_doe"
GET username:1

# determine the hash slot number associated with a key
CLUSTER KEYSLOT username:1
*/
