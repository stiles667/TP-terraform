variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the route table is created."
}

variable "route_cidr" {
  type        = string
  description = "Destination CIDR block for the route."
}
