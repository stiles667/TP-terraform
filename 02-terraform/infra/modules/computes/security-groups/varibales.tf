variable "username" {
  type        = string
  description = "The username for the instance."

}
variable "environment" {
  type        = string
  description = "The environment for the instance (e.g., dev, staging, prod)."
  validation {
    condition     = regex("^[a-z]+$", var.environment)
    error_message = "Environment must only contain lowercase letters."
  }
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}
variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the security group will be created."
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  description = "Trusted CIDR blocks permitted to use SSH. Empty by default, which denies SSH."
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.allowed_ssh_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "Each allowed_ssh_cidrs value must be a valid IPv4 or IPv6 CIDR block."
  }
}
