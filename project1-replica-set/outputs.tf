
output "bastion_public_ip" {
  description = "Connect to this IP first to access my private network"
  value       = aws_instance.bastion.public_ip
}

output "mongodb_private_ips" {
  description = "The private IPs of my MongoDB nodes"
  value       = aws_instance.mongo_nodes[*].private_i
