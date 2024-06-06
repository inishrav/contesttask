provider "aws" {
  region     = ""
  access_key = ""
  secret_key = ""
}

resource "aws_s3_bucket" "example" {
  bucket = "contest-task-001"
  //it automatically create the bucket and the index.html will be automaticatally pushed to the s3bucket of contest-task-001
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.example.bucket

  index_document {
    suffix = "index.html"
  }

  # Uncomment the following block if you have an error document
  # error_document {
  #   key = "error.html"
  # }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "s3-control" {
  bucket = aws_s3_bucket.example.bucket

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.example.bucket
  key    = "index.html"
  source = "./index.html"
  etag   = filemd5("./index.html")
  content_type = "html/html"
}

# Uncomment this block if you have an error document
# resource "aws_s3_object" "error_html" {
#   bucket = aws_s3_bucket.example.bucket
#   key    = "error.html"
#   source = "./error.html"
#   etag   = filemd5("./error.html")
# }

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.example.bucket
  depends_on = [aws_s3_bucket.example, aws_s3_bucket_public_access_block.example]
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "s3:GetObject"
        ],
        "Resource": [
          "${aws_s3_bucket.example.arn}/*"
        ]
      }
    ]
  })
}