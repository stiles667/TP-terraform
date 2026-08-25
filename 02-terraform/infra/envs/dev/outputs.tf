output "instance_id" {
  description = "ID of the EC2 instance."
  value       = module.compute.instance_id
}

output "instance_public_ip" {
  description = "Public IPv4 address of the EC2 instance."
  value       = module.compute.public_ip
}

output "ssh_command" {
  description = "Command to connect to the instance."
  value       = "ssh ec2-user@${module.compute.public_ip}"
}
