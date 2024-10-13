
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


# Define the EC2 instance
resource "aws_instance" "example" {
  ami             = var.ami_id # Amazon Linux 2023 AMI ID
  instance_type   = var.instance_type
  #key_name       = "junjie-tf-keypair-07102024"
  key_name         = aws_key_pair.generated_key.key_name # Part of additional challenge 1
  subnet_id        = aws_subnet.public_subnet_az1.id
  security_groups  = [aws_security_group.allow_ssh_http_https.id] # Use the security group
  associate_public_ip_address = true # Enable public IP

# Define the user data script
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install git -y
    yum install httpd -y
    yum install docker -y
    systemctl start httpd
    systemctl enable httpd
    usermod -a -G apache ec2-user
    chown -R ec2-user:apache /var/www
    chmod 2775 /var/www
    find /var/www -type d -exec chmod 2775 {} \;
    find /var/www -type f -exec chmod 0664 {} \;
    echo "<h1>Hello World Jun Jie from $(hostname -f)</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = var.ec2_name
  }

  
}