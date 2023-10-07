resource "aws_vpc" "VPC" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "IGW"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.VPC.id
  availability_zone = "us-west-2a"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_route_table" "Public" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "Public"
  }
}

resource "aws_route_table_association" "Public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.Public.id
}

