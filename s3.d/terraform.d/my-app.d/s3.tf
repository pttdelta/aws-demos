resource "aws_s3_bucket" "my_app_bucket" {
    bucket = "${local.bucket_name_long}"
    # acl    = "private"  ## DEFINED BY RUNING OF TERRAFORM

    tags = {
        Name        = "${var.bucket_name}"
        Environment = "Dev"
    }
}

resource "aws_s3_bucket_versioning" "my_app_bucket_versioning" {
    bucket = aws_s3_bucket.my_app_bucket.id

    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "my_app_bucket_encryption" {
    bucket = aws_s3_bucket.my_app_bucket.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}
