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
    "Name" = "IGW"
  }
}

resource "aws_subnet" "Public_Subnet1" {
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public_Subnet1"
  }
}

resource "aws_subnet" "Public_Subnet2" {
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public_Subnet2"
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

resource "aws_route_table_association" "Public1" {
  subnet_id      = aws_subnet.Public_Subnet1.id
  route_table_id = aws_route_table.Public.id
}

resource "aws_route_table_association" "Public2" {
  subnet_id      = aws_subnet.Public_Subnet2.id
  route_table_id = aws_route_table.Public.id
}
