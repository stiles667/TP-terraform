output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IPv4 address of the EC2 instance."
  value       = aws_instance.this.public_ip
}

output "key_pair_name" {
  description = "Name of the EC2 key pair."
  value       = aws_key_pair.vm_kp.key_name
}
