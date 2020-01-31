data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidrblock
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.cidrblock, 3, count.index + 4)
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
}

resource "aws_internet_gateway" "internet-gw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route" "public-default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet-gw.id
}

resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
