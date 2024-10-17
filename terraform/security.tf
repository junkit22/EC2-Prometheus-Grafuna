/*
# Create a Network ACL
resource "aws_network_acl" "main_acl" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "junjie-main-acl"
  }
}

# Associate the Network ACL with Public Subnet 1
resource "aws_network_acl_association" "public_subnet_az1_association" {
  subnet_id      = aws_subnet.public_subnet_az1.id
  network_acl_id = aws_network_acl.main_acl.id
}

# Associate the Network ACL with Public Subnet 2
resource "aws_network_acl_association" "public_subnet_az2_association" {
  subnet_id      = aws_subnet.public_subnet_az2.id
  network_acl_id = aws_network_acl.main_acl.id
}

# Add Inbound Rule to allow all traffic
resource "aws_network_acl_rule" "inbound_rule_allow_all" {
  network_acl_id = aws_network_acl.main_acl.id
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

# Allow inbound traffic on port 3000 (Grafana)
resource "aws_network_acl_rule" "inbound_rule_grafana" {
  network_acl_id = aws_network_acl.main_acl.id
  rule_number    = 130
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 3000
  to_port        = 3000
}

# Allow inbound traffic on port 9090 (Prometheus)
resource "aws_network_acl_rule" "inbound_rule_prometheus" {
  network_acl_id = aws_network_acl.main_acl.id
  rule_number    = 140
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 9090
  to_port        = 9090
}

# Allow inbound traffic on port 9100 (Node Exporter)
resource "aws_network_acl_rule" "inbound_rule_node_exporter" {
  network_acl_id = aws_network_acl.main_acl.id
  rule_number    = 150
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 9100
  to_port        = 9100

}
*/
# Security Groups Configuration

# Grafana Security Group
resource "aws_security_group" "grafana_sg" {
  vpc_id = aws_vpc.main.id

    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # EC2 Instance Connect service IPs
    #cidr_blocks = ["18.206.107.24/29"] # EC2 Instance Connect service IPs
    description = "Allow SSH from EC2 Instance Connect"
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description      = "Grafana Server"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "junjie-grafana-sg"
  }
}

# Prometheus Security Group
resource "aws_security_group" "prometheus_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # EC2 Instance Connect service IPs
    #cidr_blocks = ["18.206.107.24/29"] # EC2 Instance Connect service IPs
    description = "Allow SSH from EC2 Instance Connect"
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description      = "Prometheus Server"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "junjie-prometheus-sg"
  }
}

# Node Exporter Security Group
resource "aws_security_group" "node_exporter_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # EC2 Instance Connect service IPs
    #cidr_blocks = ["18.206.107.24/29"] # EC2 Instance Connect service IPs
     description = "Allow SSH from EC2 Instance Connect"
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description      = "Node Exporter Server"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "junjie-node-exporter-sg"
  }
}
