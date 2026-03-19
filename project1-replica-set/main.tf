provider "aws" {
  region = var.aws_region
}

# --- Networking ---

resource "aws_vpc" "project_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "project-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.project_vpc.id
}

# Public Subnet for the Bastion Host
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = { Name = "public-subnet" }
}

# Private Subnets for MongoDB Nodes (Isolation)
resource "aws_subnet" "private_subnets" {
  count                   = 3
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.project_vpc.cidr_block, 8, count.index + 10)
  availability_zone       = element(["us-east-1a", "us-east-1b", "us-east-1c"], count.index)
  map_public_ip_on_launch = false
  tags = { Name = "private-subnet-${count.index + 1}" }
}

# Routing for Public Subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.project_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# NAT Gateway for Private Subnets to reach the internet
resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.project_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "private-rt" }
}

resource "aws_route_table_association" "private_assoc" {
  count          = 3
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

# --- Security Groups ---

resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"
  vpc_id = aws_vpc.project_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "mongo_sg" {
  name   = "mongo-sg"
  vpc_id = aws_vpc.project_vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id] 
  }

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- Compute ---

resource "random_password" "mongo_key" {
  length  = 64
  special = false
}

resource "aws_instance" "bastion" {
  ami                         = "ami-0ec10929233384c7f"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  tags = { Name = "Bastion-Host" }
}

resource "aws_instance" "mongo_nodes" {
  count         = 3
  ami           = "ami-0ec10929233384c7f"
  instance_type = "t3.medium"
  key_name      = var.key_name
  subnet_id     = aws_subnet.private_subnets[count.index].id

  vpc_security_group_ids = [aws_security_group.mongo_sg.id]

  user_data = templatefile("user_data.sh.tpl", {
    keyfile_content = random_password.mongo_key.result
  })

  tags = { Name = "MongoDB-Server-${count.index + 1}" }
}

# S3 for Backups with a unique name
resource "aws_s3_bucket" "mongo_backup" {
  bucket = "sisay-mongo-backups-${random_id.bucket_suffix.hex}"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}
