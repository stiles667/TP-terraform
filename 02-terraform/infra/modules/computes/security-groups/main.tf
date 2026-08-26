locals {
  prefix = "${var.username}-${var.environment}"
}

resource "aws_security_group" "this" {
  name        = "${local.prefix}-sg"
  description = "Security group for ${local.prefix}"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${local.prefix}-sg"
    Environment = var.environment
  }
}

# Public web endpoint. Keep this rule limited to HTTP; HTTPS should be added
# separately when the service is configured for it.
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.this.id
  description       = "Allow inbound HTTP"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# SSH is fail-safe by default: no rule is created unless one or more trusted
# CIDR blocks are explicitly supplied through allowed_ssh_cidrs.
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  for_each = toset(var.allowed_ssh_cidrs)

  security_group_id = aws_security_group.this.id
  description       = "Allow inbound SSH from ${each.value}"
  cidr_ipv4         = each.value
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Defined explicitly so outbound access is intentional and visible in code.
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.this.id
  description       = "Allow all outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
