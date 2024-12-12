output "zookeeper_connect_string" {
  description = "The connection string to use to connect to the Zookeeper cluster"
  value       = aws_msk_cluster.this.zookeeper_connect_string
}

output "bootstrap_brokers" {
  description = "Comma separated list of one or more hostname:port pairs of kafka brokers suitable to bootstrap connectivity to the kafka cluster"
  value       = aws_msk_cluster.this.bootstrap_brokers
}

output "bootstrap_brokers_tls" {
  description = "TLS connection host:port pairs"
  value       = aws_msk_cluster.this.bootstrap_brokers_tls
}
