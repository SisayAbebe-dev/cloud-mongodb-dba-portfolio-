
provider "aws" {
  region     = "us-east-1"
 
}

resource "aws_instance" "mongo_nodes" {
  count         = 3
  ami           = "ami-0f3caa1cf4417e51b"
  instance_type = "t2.nano"
  key_name      = "mongodb project key p"

  subnet_id = aws_subnet.private_subnets[count.index].id

  vpc_security_group_ids = [
    aws_security_group.mongo_sg.id
  ]

  user_data = file("user_data.sh")

  tags = {
    Name = "MongoDB-Server-${count.index}"
  }
}

resource "aws_subnet" "private_subnets" {
  count                   = 3
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.project_vpc.cidr_block, 4, count.index)
  availability_zone       = element(["us-east-1a", "us-east-1b", "us-east-1c"], count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-${count.index}"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "public-subnet"
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

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.project_vpc.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  }

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.project_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "private_assoc" {
  count          = 3
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_vpc" "project_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "project-vpc"
  }
}

resource "aws_security_group" "mongo_sg" {
  name   = "mongo-sg"
  vpc_id = aws_vpc.project_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["My current ip/32"]
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


resource "aws_s3_bucket" "mongo_backup" {
  bucket = "sisay-mongo-backups-12345"
}

resource "aws_iam_role" "ec2_backup_role" {
  name = "ec2-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "backup_policy" {
  name = "mongo-backup-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:PutObject",
        "s3:ListBucket"
      ]
      Resource = [
        "arn:aws:s3:::sisay-mongo-backups-12345",
        "arn:aws:s3:::sisay-mongo-backups-12345/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_backup_policy" {
  role       = aws_iam_role.ec2_backup_role.name
  policy_arn = aws_iam_policy.backup_policy.arn
}

resource "aws_iam_instance_profile" "backup_profile" {
  name = "backup-instance-profile"
  role = aws_iam_role.ec2_backup_role.name
}
