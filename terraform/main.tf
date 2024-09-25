# AMI Lookup
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

# Kafka EC2 Instance
resource "aws_instance" "kafka_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  associate_public_ip_address = true	
  user_data = filebase64("${path.module}/scripts/user_data.sh")
  tags = {
    Name = "kafka-instance"
  }
}

# S3 bucket for storing files
resource "aws_s3_bucket" "stock-market-bucket" {
  bucket = "theplayer007-stock-market-bucket"
}

# Glue Catalog Database
resource "aws_glue_catalog_database" "stock-market-catalog-db" {
  name = "stock-market-catalog-db"
}

# Glue Crawler for S3
resource "aws_glue_crawler" "stock-market-crawler" {
  database_name = aws_glue_catalog_database.stock-market-catalog-db.name
  name          = "stock-market-crawler"
  role          = aws_iam_role.example.arn

  s3_target {
    path = "s3://${aws_s3_bucket.stock-market-bucket.bucket}"
  }
}

# Athena Database
resource "aws_s3_bucket" "athena-bucket" {
  bucket = "theplayer007-stock-market-athena-bucket"
}

resource "aws_athena_database" "athena-database" {
  name   = "stock-market-athena-db"
  bucket = aws_s3_bucket.athena-bucket.id
}

