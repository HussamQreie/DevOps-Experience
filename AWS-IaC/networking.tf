/*
EC2 access internet needs:
1) VPC
2) Subnet
3) Internet Gateway
4) Routing Table
5) Associate Routing Table with subnet
6) Determine public ip when creating an ec2 instance



*/




# Create a VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default" 
  tags = { Name = "Main VPC" }
}

# Create a public subnet
resource "aws_subnet" "public_subnet" {
    vpc_id =  aws_vpc.main_vpc.id 
    cidr_block = "10.0.1.0/24"
    availability_zone = "eu-central-1a"
    tags = {Name="Public Subnet"}
}

# Create Internet Gateway - allow vpc ec2s access internet
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main_vpc.id
    tags = {Name="Internet Gateway"}    
}

resource "aws_route_table" "route_t" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Routing Table"
  }
}


# Associate Route Table with public subnet
resource "aws_route_table_association" "route_t_a" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_t.id

}

