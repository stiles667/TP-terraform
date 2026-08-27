data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.username}-${var.environment}-vpc"
    Environment = var.environment
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.username}-${var.environment}-public-subnet"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.username}-${var.environment}-igw"
    Environment = var.environment
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name        = "${var.username}-${var.environment}-public-rt"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public.id
}

module "security_groups" {
  source = "../../modules/computes/security-groups"

  username          = var.username
  environment       = var.environment
  vpc_id            = aws_vpc.this.id
  allowed_ssh_cidrs = var.allowed_ssh_cidrs
}

module "compute" {
  source = "../../modules/computes"

  username      = var.username
  environment   = var.environment
  public_key    = file(pathexpand("~/.ssh/tp-terraform-dev-ed25519.pub"))
  has_public_ip = true
  instance_ami  = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id
  sg_ids        = [module.security_groups.id]
}
