resource "aws_route_table" "this" {
  vpc_id = var.vpc_id

  route {
    cidr_block = var.route_cidr
  }
}
