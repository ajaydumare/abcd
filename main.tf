# Define the provider
provider "aws" {
  access_key = ""

  secret_key = ""
  region     = "us-west-2"  # Change the region as per your requirement
}

# Create a VPC
resource "aws_vpc" "project_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "project-vpc"
  }
}

# Create subnets
resource "aws_subnet" "dev_subnet" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"  # Change as needed
  tags = {
    Name = "Dev"
  }
}

resource "aws_subnet" "test_subnet" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"  # Change as needed
  tags = {
    Name = "Test"
  }
}

resource "aws_subnet" "devops_subnet" {
  vpc_id            = aws_vpc.project_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2c"  # Change as needed
  tags = {
    Name = "DevOps"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "project_gtw" {
  vpc_id = aws_vpc.project_vpc.id
  tags = {
    Name = "ProjectGtw"
  }
}

# Create a Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.project_vpc.id
  tags = {
    Name = "PublicRT"
  }
}

# Create a route in the route table that directs traffic to the Internet Gateway
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.project_gtw.id
}

# Associate the Public Route Table with the subnets
resource "aws_route_table_association" "dev_rt_association" {
  subnet_id      = aws_subnet.dev_subnet.id
  route_table_id = aws_route_table.public_rt.id
  depends_on     = [aws_route.internet_access]
}

resource "aws_route_table_association" "test_rt_association" {
  subnet_id      = aws_subnet.test_subnet.id
  route_table_id = aws_route_table.public_rt.id
  depends_on     = [aws_route.internet_access]
}

resource "aws_route_table_association" "devops_rt_association" {
  subnet_id      = aws_subnet.devops_subnet.id
  route_table_id = aws_route_table.public_rt.id
  depends_on     = [aws_route.internet_access]
}

# Create a Security Group with all inbound and outbound ports open
resource "aws_security_group" "project_sg" {
  name   = "project-security-group"
  vpc_id = aws_vpc.project_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project-security-group"
  }
}

# Create EC2 Instances
resource "aws_instance" "dev_instance" {
  ami                         = "ami-000089c8d02060104"  # Replace with a valid AMI ID
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.dev_subnet.id
  vpc_security_group_ids      = [aws_security_group.project_sg.id]
  key_name                    = "09-nov-24"
  associate_public_ip_address = true

  tags = {
    Name = "Dev-instance"
  }
  depends_on = [aws_security_group.project_sg]
}

resource "aws_instance" "test_instance" {
  ami                         = "ami-000089c8d02060104"  # Replace with a valid AMI ID
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.test_subnet.id
  vpc_security_group_ids      = [aws_security_group.project_sg.id]
  key_name                    = "09-nov-24"
  associate_public_ip_address = true

  tags = {
    Name = "Test-instance"
  }
  depends_on = [aws_security_group.project_sg]
}

resource "aws_instance" "devops_instance" {
  ami                         = "ami-000089c8d02060104"  # Replace with a valid AMI ID
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.devops_subnet.id
  vpc_security_group_ids      = [aws_security_group.project_sg.id]
  key_name                    = "09-nov-24"
  associate_public_ip_address = true

  tags = {
    Name = "DevOps-instance"
  }
  depends_on = [aws_security_group.project_sg]
}
