provider "aws" {
  region = "us-east-1"
}


resource "aws_vpc" "project_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "project3-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "project3-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "mongo_sg" {
  name   = "mongo-sg"
  vpc_id = aws_vpc.project_vpc.id

  # SSH from my IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # MongoDB internal communication
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mongo-sg"
  }
}

resource "aws_instance" "mongo_nodes" {
  count         = 3
  ami           = "ami-0b6c6ebed2801a5cb" 
  instance_type = "t2.micro"
  key_name      = var.key_name


  subnet_id = aws_subnet.public_subnet.id

  vpc_security_group_ids = [
    aws_security_group.mongo_sg.id
  ]

  user_data = file("user_data_node${count.index + 1}.sh")

  tags = {
    Name = "MongoDB-Node-${count.index + 1}"
  }
}
