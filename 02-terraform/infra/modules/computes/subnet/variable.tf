
variable "vpc_id" {
  type = string
}
variable "username" {
  type = string
}
variable "environment" {
  type = string
}
variable "subnet_cidr" {
  type = string
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.subnet_cidr))
    error_message = "Must be 4bytes/cidr."
  }
}
