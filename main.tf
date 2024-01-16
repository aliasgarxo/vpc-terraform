provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}


#VPC
resource "aws_vpc" "zing-vpc" {
  cidr_block = "69.69.0.0/16"
  tags = {
    Name = "zing-vpc"
  }
}

# SUBNETS

resource "aws_subnet" "zing-pub-sub-1" {
  vpc_id     = aws_vpc.zing-vpc.id
  cidr_block = "69.69.1.0/24"
  availability_zone = var.azs-a
  map_public_ip_on_launch = true

  tags = {
    Name = "zing-pub-sub-1"
  }
}
resource "aws_subnet" "zing-pub-sub-2" {
  vpc_id     = aws_vpc.zing-vpc.id
  cidr_block = "69.69.2.0/24"
  availability_zone = var.azs-b
  map_public_ip_on_launch = true

  tags = {
    Name = "zing-pub-sub-2"
  }
}
resource "aws_subnet" "zing-pri-sub-1" {
  vpc_id     = aws_vpc.zing-vpc.id
  cidr_block = "69.69.3.0/24"
  availability_zone = var.azs-a
  map_public_ip_on_launch = false

  tags = {
    Name = "zing-pri-sub-1"
  }
}
resource "aws_subnet" "zing-pri-sub-2" {
  vpc_id     = aws_vpc.zing-vpc.id
  cidr_block = "69.69.4.0/24"
  availability_zone = var.azs-b
  map_public_ip_on_launch = false

  tags = {
    Name = "zing-pri-sub-2"
  }
}

# SECURITY GROUP

resource "aws_security_group" "zing-sg" {
  name        = "zing-sg"
  description = "Allow ALL inbound traffic"
  vpc_id      = aws_vpc.zing-vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "zing-sg"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "zing-igw" {
  vpc_id = aws_vpc.zing-vpc.id

  tags = {
    Name = "zing-igw"
  }
}


# Create route tables and route table associations
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.zing-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.zing-igw.id
  }

  tags = {
    Name = "public_route"
  }
}

resource "aws_route_table_association" "public_route_association-1" {
  subnet_id      = aws_subnet.zing-pub-sub-1.id
  route_table_id = aws_route_table.public_route.id
}
resource "aws_route_table_association" "public_route_association-2" {
  subnet_id      = aws_subnet.zing-pub-sub-2.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table" "private_route-1" {
  vpc_id = aws_vpc.zing-vpc.id
#   route {

#   }
  tags = {
    Name = "private_route_1"
  }
}

resource "aws_route_table_association" "private-route-1" {
  subnet_id      = aws_subnet.zing-pri-sub-1.id
  route_table_id = aws_route_table.private_route-1.id
}

resource "aws_route_table" "private_route-2" {
  vpc_id = aws_vpc.zing-vpc.id
#   route {

#   }
  tags = {
    Name = "private_route_2"
  }
}

resource "aws_route_table_association" "private-route-2" {
  subnet_id      = aws_subnet.zing-pri-sub-2.id
  route_table_id = aws_route_table.private_route-2.id
}