# Create AWS S3
resource "aws_s3_bucket" "bucket" {
  #Change to unique name
  bucket = "junjie-s3-tf-07102024"

  tags = {
    Name        = "junjie bucket"
    Environment = "Dev"
    Department  = "DevOps"
  }
}
