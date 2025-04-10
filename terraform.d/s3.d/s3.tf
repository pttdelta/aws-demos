

resource "aws_s3_bucket" "my_bucket" {
  bucket = local.bucket_name_long
  # acl    = "private"  ## DEFINED BY RUNNING OF TERRAFORM

  lifecycle {
    prevent_destroy = false
  }
  force_destroy = false

  tags = {
    Name        = "${var.bucket_name}"
    Environment = "${var.env}"
  }
}

resource "aws_s3_bucket_versioning" "my_bucket_versioning" {
  bucket = aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "Policy1743756012415",
    "Statement": [
        {
            "Sid": "Stmt1743755887622",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.my_bucket.arn}/*",
            "Condition": {
                "Null": {
                    "s3:x-amz-server-side-encryption": "true"
                }
            }
        }
    ]
}
    POLICY
}

resource "aws_s3_bucket_server_side_encryption_configuration" "my_bucket_encryption" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_key.id
    }
    bucket_key_enabled = true # Enable S3 Bucket Key for improved performance and cost reduction
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "my_bucket_lifecycle" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    id     = "delete_old_objects"
    status = "Enabled"

    filter {
      and {
        prefix                   = "30dayfiles" # Applies to all objects in the bucket
        object_size_greater_than = 1
        object_size_less_than    = 20 * 1024
        tags = {
          rule      = "log"
          autoclean = "true"
        }
      }
    }

    expiration {
      days = 30 # Delete objects older than 30 days
    }
  }
}
