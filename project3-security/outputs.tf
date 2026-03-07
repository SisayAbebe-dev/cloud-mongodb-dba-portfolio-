
output "mongo_public_ips" {
  value = aws_instance.mongo_nodes[*].public_ip
}

output "mongo_private_ips" {
  value = aws_instance.mongo_nodes[*].private_ip
}
