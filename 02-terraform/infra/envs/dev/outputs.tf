output "security_group_id" {
  description = "ID of the security group."
  value       = module.security_groups.id
}
output "subnet_id" {
  description = "ID of the subnet."
  value       = aws_subnet.public.id
}
output "vm_public_ip" {
  description = "Public IP address of the EC2 instance."
  value       = module.compute.public_ip
}

