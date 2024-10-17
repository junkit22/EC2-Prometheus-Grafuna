# Variable for AWS region
variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

# Variable for instance type of Grafana
variable "grafana_instance" {
  description = "Instance type for Grafana"
  type        = string
  default     = "t2.micro"
}

# Variable for VPC Name
variable "vpc_name" {
  description = "Name of VPC to use"
  type        = string
  default     = "junjie-tf-vpc" # Update with your own VPC name, found under VPC > your VPC > Tags > value of Name
}

# Variable for security group name of Grafana
variable "security_group_name" {
  description = "Grafana security group name"
  type        = string
  default     = "grafana-security-group"
}

# Variable for instance type of Prometheus
variable "prometheus_instance" {
  description = "Instance type for Prometheus"
  type        = string
  default     = "t2.micro"
}

# Variable for security group name of Prometheus
variable "prom_security_group_name" {
  description = "Prometheus security group name"
  type        = string
  default     = "prometheus-security-group"
}

# Variable for instance type of Node Exporter
variable "node_exporter_instance" {
  description = "Instance type for Node Exporter"
  type        = string
  default     = "t2.micro"
}

# Variable for security group name of Node Exporter
variable "node_exporter_security_group_name" {
  description = "Prometheus security group name"
  type        = string
  default     = "node-exporter-security-group"
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
  default     = "ami-0427090fd1714168b"
}

variable "ec2_name" {
  description = "Name of EC2"
  type        = string
  default     = "junjie-tf-ec2" # Replace with your preferred EC2 Instance Name 
}

variable "instance_type" {
  description = "EC2 Instance type"
  type        = string
  default     = "t2.micro"
}