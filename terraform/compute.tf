## Additional Challenge 1 - Create Key Pair and download to local file
# Create EC2 Key Pair
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "generated_key" {
  key_name   = "junjie-tf-keypair-07102024"
  public_key = tls_private_key.example.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.example.private_key_pem
  filename = "/home/junkit22/junjie-tf-keypair-07102024.pem"
  provisioner "local-exec" {
    command = "chmod 400 /home/junkit22/junjie-tf-keypair-07102024.pem"
  }
}

/*
# Define data source to fetch the latest Ubuntu AMI for Ubuntu 24.04 from AWS
data "aws_ami" "server_ami" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
*/

# Define the EC2 instance
resource "aws_instance" "example" {
  ami             = var.ami_id # Amazon Linux 2023 AMI ID
  instance_type   = var.instance_type
  #key_name       = "junjie-useast1-13072024"
  key_name         = aws_key_pair.generated_key.key_name # Part of additional challenge 1
  subnet_id        = aws_subnet.public_subnet_az1.id
  # security_groups  = [aws_security_group.allow_ssh_http_https.id] # Use the security group
  associate_public_ip_address = true # Enable public IP

}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "junjie-tf-vpc"
  }
}

# Define Public Subnet 1 in AZ1
resource "aws_subnet" "public_subnet_az1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.5.0/24"
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


# AWS instance for Grafana
resource "aws_instance" "Grafana" {
  ami             = var.ami_id # Amazon Linux 2023 AMI ID
  instance_type          = var.grafana_instance
  subnet_id              = aws_subnet.public_subnet_az1.id
  vpc_security_group_ids = [aws_security_group.grafana_sg.id]

  # Enable public IP
  associate_public_ip_address = true

  # Use generated key pair
  key_name               = aws_key_pair.generated_key.key_name

  # User Data in AWS EC2
  user_data = file("grafana install.sh")

  tags = {
    Name = "junjie-Grafana"
  }
}

# AWS instance for Prometheus
resource "aws_instance" "Prometheus" {
  ami             = var.ami_id # Amazon Linux 2023 AMI ID
  instance_type          = var.prometheus_instance
  subnet_id              = aws_subnet.public_subnet_az1.id
  vpc_security_group_ids = [aws_security_group.prometheus_sg.id]

  # Enable public IP
  associate_public_ip_address = true

  # Use generated key pair
  key_name               = aws_key_pair.generated_key.key_name

  tags = {
    Name = "junjie-Prometheus"
  }
}

# AWS instance for Node Exporter
resource "aws_instance" "Node_Exporter" {
  ami             = var.ami_id # Amazon Linux 2023 AMI ID
  instance_type          = var.node_exporter_instance
  subnet_id              = aws_subnet.public_subnet_az1.id
  vpc_security_group_ids = [aws_security_group.node_exporter_sg.id]

  # Enable public IP
  associate_public_ip_address = true

  # Use generated key pair
  key_name               = aws_key_pair.generated_key.key_name

  # User Data in AWS EC2
  user_data = file("apache install.sh")

  tags = {
    Name = "junjie-Node Exporter"
  }
}