


variable "username" {
  type        = string
  description = "The username for the instance."

}
variable "public_key" {
  type        = string
  description = "The public key to use for the instance's key pair."

}
variable "has_public_ip" {
  type        = bool
  default     = false #failback to false if not provided
  description = "Whether to associate a public IP address with the instance."

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







variable "instance_ami" {
  type        = string
  description = "The AMI ID to use for the instance."

}
variable "instance_type" {
  type        = string
  description = "The type of instance to create."

}
variable "subnet_id" {
  type        = string
  description = "The ID of the subnet to launch the instance in."

}

variable "sg_ids" {
  type        = list(string)
  description = "A list of security group IDs to associate with the instance."

}
