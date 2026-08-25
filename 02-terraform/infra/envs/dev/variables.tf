variable "aws_region" {
  type        = string
  description = "AWS region where the development instance is created."
  default     = "eu-west-1"
}

variable "username" {
  type        = string
  description = "Name used in resource names and tags."
  default     = "developer"
}

variable "environment" {
  type        = string
  description = "Deployment environment."
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "public_key" {
  type        = string
  description = "SSH public key installed on the EC2 instance."
  sensitive   = true
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type."
  default     = "t3.micro"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for the public subnet."
  default     = "10.0.1.0/24"
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "CIDR block allowed to connect to SSH. Restrict this in real deployments."
  default     = "0.0.0.0/0"
}
