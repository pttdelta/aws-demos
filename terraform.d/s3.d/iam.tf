resource "aws_iam_role" "s3_access_role" {
  name = "S3AccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::650897784733:user/Andyf-Developer" # Replace with the AWS account ID or specific entity
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach a policy directly to the role to allow access to the S3 bucket
#resource "aws_iam_role_policy" "s3_access_policy" {
#  name = "s3-access-policy"
# role = aws_iam_role.s3_access_role.id
#
#  # S3 full access policy (customize if needed)
#  policy = jsonencode({
#    Version = "2012-10-17"
#    Statement = [
#      {
#        Effect = "Allow"
#        Action = "s3:*"
#        Resource = [
#          aws_s3_bucket.my_bucket.arn,       # S3 bucket
#          "${aws_s3_bucket.my_bucket.arn}/*" # All objects inside the bucket
#        ]
#      }
#    ]
#  })
#}