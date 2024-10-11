terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


#Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  # Edit below
  #access_key = "my-access-key"
  #secret_key = "my-secret-key"
}