output "sb_id" {
  description = "ID of the subnet."
  value       = aws_subnet.this.id
}
output "sb_cidr" {
  description = "CIDR of the subnet."
  value       = aws_subnet.this.cidr_block
}