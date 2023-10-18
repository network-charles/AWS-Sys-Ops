resource "aws_vpc" "VPC" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC"
  }
}

resource "aws_subnet" "Private_Subnet" {
  vpc_id            = aws_vpc.VPC.id
  availability_zone = "eu-west-2a"
  cidr_block        = "10.0.1.0/24"
  # A non-compliant attribute
  map_public_ip_on_launch = true

  tags = {
    Name = "Private_Subnet"
  }
}

resource "aws_subnet" "Public_subnet" {
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "Public_Subnet"
  }
}
