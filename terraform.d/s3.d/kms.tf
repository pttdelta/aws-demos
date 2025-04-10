# Create the KMS key (you can also use the default AWS-managed KMS key for S3)
resource "aws_kms_key" "s3_key" {
  description = "KMS key for encrypting S3 bucket"
  enable_key_rotation = true
}
