#VPC called (my_vpc) 
resource "aws_vpc" "my_vpc" {
  cidr_block             = "172.16.0.0/16"
  enable_dns_support     = true
  enable_dns_hostnames   = true
  tags = {
    Name = "test_vpc"
  }
}
#Elastic IP for NAT
resource "aws_eip" "nat_eip" {
  domain        = "vpc"
}
# NAT 
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public-subnet.id
  depends_on    = [aws_internet_gateway.internet-gateway]
  tags = {
    Name        = "nat"
  }
}

#Internet GW
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.my_vpc.id
}

#Public subnet
resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  availability_zone       = "us-east-1b"
  cidr_block              = "172.16.11.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public subnet"
  }
}
# Route table public
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.my_vpc.id
}

# Route for public subnet
resource "aws_route" "public-subnet-route" {
  route_table_id         = aws_route_table.public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet-gateway.id
}
# Private route table
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.my_vpc.id
}

# Route for private subnet (using NAT Gateway)
resource "aws_route" "private-subnet-route" {
  route_table_id         = aws_route_table.private-route-table.id
  destination_cidr_block = "172.16.10.0/24"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

#route table assiocioation
#public
resource "aws_route_table_association" "public-subnet-route-table-assiocioation" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-route-table.id
}
#private table ass
resource "aws_route_table_association" "private-subnet-route-table-assiocioation" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.private-route-table.id
}

#private Subnet
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "172.16.10.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
}


#private interface1 
resource "aws_network_interface" "ec2_int1" {
  subnet_id       = aws_subnet.my_subnet.id
  private_ips     = ["172.16.10.100"]
  security_groups = [aws_security_group.first.id]
attachment {
    instance      = aws_instance.webtestinstance.id
    device_index  = 1
  }
  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_security_group" "first" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "jasper SG"

ingress {
from_port   = 0
to_port     = 0
protocol    = "-1"
cidr_blocks = ["0.0.0.0/0"]
}

#all outbound
egress {
from_port   = 0
to_port     = 0
protocol    = "-1"
cidr_blocks = ["0.0.0.0/0"]

  }
}

