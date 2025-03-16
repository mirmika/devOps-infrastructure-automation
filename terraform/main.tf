# Declare varaibles for existing resources in AWS
data "aws_key_pair" "ssh_key" {
  key_name = "vpc-connection-key"
}

# add AMI Data Source
data "aws_ami" "ubuntu" {
  most_recent = true # select the latest Ubuntu 20.04 LTS Amazon Machine Image (AMI) from AWS

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"] # wildcard (*) ensures that any newer AMI versions matching this name pattern will be included
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"] # ensures the AMI has hardware-assisted virtualization (HVM)
  }

  owners = ["099720109477"] # belongs to Canonical, the official provider of Ubuntu AMIs
}
/***************************** VPC Configuration ***********************************/
# Create a VPC with a CIDR block
resource "aws_vpc" "devops_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "devops-team-vpc"
  }
}

# Add a public subnet resource
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.devops_vpc.id #associate subnet with the VPC created earlier
  cidr_block              = "10.0.41.0/24"
  map_public_ip_on_launch = true # instances launched in this subnet will automatically receive public IP addresses
  availability_zone       = "us-west-2a"

  tags = {
    Name = "public-subnet-devops"
  }
}

# Add an Internet Gateway (IGW) to provide Internet access
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.devops_vpc.id

  tags = {
    Name = "Internet-Gateway"
  }
}

# Define a route table that directs outbound traffic to the IGW
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.devops_vpc.id

  route {
    cidr_block = "0.0.0.0/0" #route defined sends all traffic (0.0.0.0/0) to the Internet Gateway
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

# Associate the Public Subnet with the Route Table. 
# This association ensures that instances in the public subnet follow the routing rules defined in the route table
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
/****************** Use module block to instantiate 3 private subnets ***************************/
module "private_subnet_1" {
  source            = "./modules/private-subnet"
  vpc_id            = aws_vpc.devops_vpc.id # Use ID of vpc as the value for the vpc_id variable inside the private-subnet module. 
  cidr_block        = "10.0.42.0/24"
  availability_zone = "us-west-2b"
  subnet_name       = "private-subnet-1"
}

module "private_subnet_2" {
  source            = "./modules/private-subnet"
  vpc_id            = aws_vpc.devops_vpc.id 
  cidr_block        = "10.0.43.0/24"
  availability_zone = "us-west-2c" 
  subnet_name       = "private-subnet-2"
}

module "private_subnet_3" {
  source            = "./modules/private-subnet"
  vpc_id            = aws_vpc.devops_vpc.id
  cidr_block        = "10.0.44.0/24"
  availability_zone = "us-west-2d" 
  subnet_name       = "private-subnet-3"
}

# NAT Gateway requires an Elastic IP (EIP) to allow outbound internet access
resource "aws_eip" "nat_gw_ip" {
  domain = "vpc"

  tags = {
    Name = "NAT-Gateway-EIP"
  }
}

# Create a NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_gw_ip.id
  subnet_id     = aws_subnet.public_subnet.id  # the NAT Gateway will be placed in the public subnet to allow private subnet instances to access the internet

  tags = {
    Name = "NAT-Gateway"
  }
}

#Create a Route Table for the Private Subnet
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.devops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "PrivateRouteTable"
  }
}

# Associate the PrivateRouteTable with the Private Subnet 1.
resource "aws_route_table_association" "private_rt_assoc" {
  subnet_id      = module.private_subnet_3.subnet_id
  route_table_id = aws_route_table.private_rt.id
}

output "private_subnet_1_id" {
  value = module.private_subnet_1.subnet_id
}

output "private_subnet_2_id" {
  value = module.private_subnet_2.subnet_id
}

output "private_subnet_3_id" {
  value = module.private_subnet_3.subnet_id
}





