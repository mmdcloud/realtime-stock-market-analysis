# Glue IAM Role
resource "aws_iam_role" "glue_role" {
  name               = "stock-market-glue-role"
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role_policy.json
}

data "aws_iam_policy_document" "glue_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "glue_policy" {
  name        = "stock-market-glue-policy"
  description = "Policy for Glue to access necessary resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_policy_attachment" {
  policy_arn = aws_iam_policy.glue_policy.arn
  role       = aws_iam_role.glue_role.name
}


# AMI Lookup
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

# Kafka EC2 Instance
resource "aws_instance" "kafka_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = "shiv"
  associate_public_ip_address = true
  user_data                   = filebase64("${path.module}/scripts/user_data.sh")
  tags = {
    Name = "kafka-instance"
  }
}

# S3 bucket for storing files
resource "aws_s3_bucket" "stock-market-bucket" {
  force_delete = true
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
  role          = aws_iam_role.glue_role.arn

  s3_target {
    path = "s3://${aws_s3_bucket.stock-market-bucket.bucket}"
  }
}

# Athena Database
resource "aws_s3_bucket" "athena-bucket" {
  force_delete = true
  bucket = "theplayer007-stock-market-athena-bucket"
}

resource "aws_athena_database" "athena-database" {
  name   = "stock_market_athena_db"
  bucket = aws_s3_bucket.athena-bucket.id
}

