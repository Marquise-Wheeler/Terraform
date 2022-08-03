# vpc_automation.tf | Automation of VPC, Subnets, Gateways, EIP and Routes.

provider "aws" {
  region = "us-east-1"
  # Configuration options
}

# Main VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Main VPC"
  }
}

# Public Subnet with Default Route to Internet Gateway
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Public Subnet"
  }
}

# Private Subnet with Default Route to NAT Gateway
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Private Subnet"
  }
}

# Main Internet Gateway for VPC
# https://registry.terraform.io/providers/aaronfeng/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main IGW"
  }
}

# Create the EIP used by IGW 
# EIP cost $ if not attached 
# https://registry.terraform.io/providers/aaronfeng/aws/latest/docs/resources/eip
resource "aws_eip" "nat_eip" {
  depends_on = [aws_internet_gateway.igw]
  vpc      = true

  tags = {
      Name = "NAT Gateway EIP"
  }
}

# Create NAT Gateway to be placed in Public subnet
# https://registry.terraform.io/providers/aaronfeng/aws/latest/docs/resources/nat_gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "Main NAT Gateway"
  }
}

# Create Route Table for Public Subnet
# https://registry.terraform.io/providers/aaronfeng/aws/latest/docs/resources/route_table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

    tags = {
    Name = "Public Route Table"
  }
}

# Assc=ociate route table with Public Subnet
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "public" {
  subnet_id      =  aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Create Route Table for Private Subnet
# https://registry.terraform.io/providers/aaronfeng/aws/latest/docs/resources/route_table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

    tags = {
    Name = "Private Route Table"
  }
}

# Asscociate route table with Private Subnet
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "private" {
  subnet_id      =  aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
