# Define a security group
resource "aws_security_group" "allow_ssh_http_https" {
  name        = "junjie-tf-sg-allow-ssh-http-https"
  description = "Security Group to allow SSH, HTTP, and HTTPS traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = var.sg_name
  }

  # Ingress rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH from anywhere"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from anywhere"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from anywhere"
  }

ingress {
    description      = "Custom TCP - Grafana"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Custom TCP - Prometheus"
    from_port        = 9090
    to_port          = 9090
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Custom TCP - Node Exporter"
    from_port        = 9100
    to_port          = 9100
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  # Egress rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}


#Create VPC
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
  }
}

# Define Public Subnet 1 in AZ1
resource "aws_subnet" "public_subnet_az1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "junjie-tf-public-subnet-az1"
  }
}

# Define Public Subnet 2 in AZ2
resource "aws_subnet" "public_subnet_az2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "junjie-tf-public-subnet-az2"
  }
}

# Define Private Subnet 1 in AZ1
resource "aws_subnet" "private_subnet_az1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "junjie-tf-private-subnet-az1"
  }
}

# Define Private Subnet 2 in AZ2
resource "aws_subnet" "private_subnet_az2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "junjie-tf-private-subnet-az2"
  }
}

# Define internet gateway 
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "junjie-tf-igw"
  }
}

# Define VPC Endpoint for S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.us-east-1.s3"

  tags = {
    Environment = "junjie-tf-vpce-s3"
    Name = "junjie-tf-vpc-vpce-3"
  }
}

# Define a route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "junjie-tf-public-rtb"
  }
}

# Associate the public subnet 1 with the public route table
resource "aws_route_table_association" "public_subnet_az1_association" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  route_table_id = aws_route_table.public.id
}

# Associate the public subnet 2 with the public route table
resource "aws_route_table_association" "public_subnet_az2_association" {
  subnet_id      = aws_subnet.public_subnet_az2.id
  route_table_id = aws_route_table.public.id
}

# Define a route table for private subnet az1
resource "aws_route_table" "private_az1" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "junjie-tf-private-rtb-az1"
  }
}

# Associate the private subnet 1 with the private route table
resource "aws_route_table_association" "private_subnet_az1_association" {
  subnet_id      = aws_subnet.private_subnet_az1.id
  route_table_id = aws_route_table.private_az1.id
}

# Define a route table for private subnet az2
resource "aws_route_table" "private_az2" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "junjie-tf-private-rtb-az2"
  }
}


# Associate the private subnet 2 with the private route table
resource "aws_route_table_association" "private_subnet_az2_association" {
  subnet_id      = aws_subnet.private_subnet_az2.id
  route_table_id = aws_route_table.private_az2.id
}

resource "aws_network_acl" "my_acl" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_network_acl_association" "my_acl_association" {
  subnet_id      = aws_subnet.my_subnet.id
  network_acl_id = aws_network_acl.my_acl.id
}

# Inbound rule for all traffic (rule number 100)
resource "aws_network_acl_rule" "allow_all_traffic" {
  network_acl_id = aws_network_acl.my_acl.id
  rule_number    = 100
  egress         = false
  protocol       = "-1"  # -1 means all protocols
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0

}

# Inbound rule for custom TCP port 9090 (rule number 101)
resource "aws_network_acl_rule" "allow_tcp_9090" {
  network_acl_id = aws_network_acl.my_acl.id
  rule_number    = 101
  egress         = false
  protocol       = "6"   # 6 means TCP
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 9090
  to_port        = 9090
}

# Inbound rule for custom TCP port 3000 (rule number 102)
resource "aws_network_acl_rule" "allow_tcp_3000" {
  network_acl_id = aws_network_acl.my_acl.id
  rule_number    = 102
  egress         = false
  protocol       = "6"   # 6 means TCP
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 3000
  to_port        = 3000
}

# Inbound rule for custom TCP port 9100 (rule number 103)
resource "aws_network_acl_rule" "allow_tcp_9100" {
  network_acl_id = aws_network_acl.my_acl.id
  rule_number    = 103
  egress         = false
  protocol       = "6"   # 6 means TCP
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 9100
  to_port        = 9100
}