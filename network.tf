#VPC called (my_vpc) 
resource "aws_vpc" "my_vpc" {
  cidr_block             = var.vpc_cidr_block
  enable_dns_support     = true
  enable_dns_hostnames   = true
  tags = {
    Name = "test_vpc"
  }
}
#Internet GW
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.my_vpc.id
}

#Public subnet
resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  availability_zone       = var.availability_zone_public
  cidr_block              = var.public_subnet_cidr_block
  map_public_ip_on_launch = true
  tags = {
    Name = "public subnet"
  }
}
#private Subnet
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.private_subnet_cidr_block
  availability_zone       = var.availability_zone_private
  map_public_ip_on_launch = false
  tags = {
    Name = "Private subnet"
  }

}
# Route table public
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.my_vpc.id
}
# Private route table
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.my_vpc.id
}
# Route for public subnet
resource "aws_route" "public-subnet-route" {
  route_table_id         = aws_route_table.public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet-gateway.id
}

# Route table assiocioation ########################################
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
#END Route table assiocioation ########################################

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
from_port   = 80
to_port     = 80
protocol    = "TCP"
cidr_blocks = ["0.0.0.0/0"]
}
ingress {
from_port   = 443
to_port     = 443
protocol    = "TCP"
cidr_blocks = ["0.0.0.0/0"]
}
ingress {
from_port   = 3306
to_port     = 3306
protocol    = "TCP"
cidr_blocks = ["0.0.0.0/0"]
}
ingress {
from_port   = 22
to_port     = 22
protocol    = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
ingress {
from_port   = 3389
to_port     = 3389
protocol    = "TCP"
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
