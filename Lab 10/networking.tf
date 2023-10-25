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

resource "aws_subnet" "Private_Subnet1" {
  vpc_id            = aws_vpc.VPC.id
  availability_zone = "eu-west-2a"
  cidr_block        = "10.0.1.0/24"

  tags = {
    Name = "Private_Subnet1"
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

resource "aws_subnet" "Private_Subnet2" {
  vpc_id            = aws_vpc.VPC.id
  availability_zone = "eu-west-2b"
  cidr_block        = "10.0.3.0/24"

  tags = {
    Name = "Private_Subnet2"
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

resource "aws_eip" "NGW1" {
  domain = "vpc"
}

resource "aws_eip" "NGW2" {
  domain = "vpc"
}

resource "aws_nat_gateway" "NGW1" {
  allocation_id = aws_eip.NGW1.id
  subnet_id     = aws_subnet.Public_Subnet1.id

  tags = {
    Name = "NGW1"
  }

  depends_on = [aws_internet_gateway.IGW]
}

resource "aws_nat_gateway" "NGW2" {
  allocation_id = aws_eip.NGW2.id
  subnet_id     = aws_subnet.Public_Subnet2.id

  tags = {
    Name = "NGW2"
  }

  depends_on = [aws_internet_gateway.IGW]
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

resource "aws_route_table" "Private1" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NGW1.id
  }

  tags = {
    Name = "Private1"
  }
}

resource "aws_route_table" "Private2" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NGW2.id
  }

  tags = {
    Name = "Private2"
  }
}

resource "aws_route_table_association" "Private1" {
  subnet_id      = aws_subnet.Private_Subnet1.id
  route_table_id = aws_route_table.Private1.id
}

resource "aws_route_table_association" "Private2" {
  subnet_id      = aws_subnet.Private_Subnet2.id
  route_table_id = aws_route_table.Private2.id
}

resource "aws_route_table_association" "Public1" {
  subnet_id      = aws_subnet.Public_Subnet1.id
  route_table_id = aws_route_table.Public.id
}

resource "aws_route_table_association" "Public2" {
  subnet_id      = aws_subnet.Public_Subnet2.id
  route_table_id = aws_route_table.Public.id
}
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

resource "aws_subnet" "Private_Subnet1" {
  vpc_id            = aws_vpc.VPC.id
  availability_zone = "eu-west-2a"
  cidr_block        = "10.0.1.0/24"

  tags = {
    Name = "Private_Subnet1"
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

resource "aws_subnet" "Private_Subnet2" {
  vpc_id            = aws_vpc.VPC.id
  availability_zone = "eu-west-2b"
  cidr_block        = "10.0.3.0/24"

  tags = {
    Name = "Private_Subnet2"
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

resource "aws_eip" "NGW1" {
  domain = "vpc"
}

resource "aws_eip" "NGW2" {
  domain = "vpc"
}

resource "aws_nat_gateway" "NGW1" {
  allocation_id = aws_eip.NGW1.id
  subnet_id     = aws_subnet.Public_Subnet1.id

  tags = {
    Name = "NGW1"
  }

  depends_on = [aws_internet_gateway.IGW]
}

resource "aws_nat_gateway" "NGW2" {
  allocation_id = aws_eip.NGW2.id
  subnet_id     = aws_subnet.Public_Subnet2.id

  tags = {
    Name = "NGW2"
  }

  depends_on = [aws_internet_gateway.IGW]
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

resource "aws_route_table" "Private1" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NGW1.id
  }

  tags = {
    Name = "Private1"
  }
}

resource "aws_route_table" "Private2" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NGW2.id
  }

  tags = {
    Name = "Private2"
  }
}

resource "aws_route_table_association" "Private1" {
  subnet_id      = aws_subnet.Private_Subnet1.id
  route_table_id = aws_route_table.Private1.id
}

resource "aws_route_table_association" "Private2" {
  subnet_id      = aws_subnet.Private_Subnet2.id
  route_table_id = aws_route_table.Private2.id
}

resource "aws_route_table_association" "Public1" {
  subnet_id      = aws_subnet.Public_Subnet1.id
  route_table_id = aws_route_table.Public.id
}

resource "aws_route_table_association" "Public2" {
  subnet_id      = aws_subnet.Public_Subnet2.id
  route_table_id = aws_route_table.Public.id
}
