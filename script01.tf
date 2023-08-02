terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = "ap-south-1"
}
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MyVPC"
  }
}
resource "aws_subnet" "main" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.0.0/20"
    availability_zone = "ap-south-1a"
    tags = {
        Name="Mysubnet1"
    }
}
resource "aws_subnet" "main2" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.16.0/20"
    availability_zone = "ap-south-1b"
    tags = {
        Name="Mysubnet2"
    }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}
resource "aws_route_table" "myroute" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "MyRouteTable"
    }
}
resource "aws_route" "myroute2" {
    route_table_id = aws_route_table.myroute.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
}

# Create an EC2 instance
resource "aws_security_group" "mysg" {
    name = "my-security-group"
    description = "Allow ssh"

ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
}
resource "aws_instance" "myec2" {
    ami = "ami-0f5ee92e2d63afc18"
    instance_type="t2.micro"
    key_name = "awsvpc"
    security_groups = [aws_security_group.mysg.name]
    count=5
}
