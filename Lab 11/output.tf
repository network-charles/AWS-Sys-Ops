output "Memcached_Endpoint" {
  value = "telnet ${aws_elasticache_cluster.Memcached.cluster_address} 11211"
}

/*
# To set a key-value pair
set key 0 0 5
value

# To retrieve a value
get key

# To delete a key
delete mkey
*/
