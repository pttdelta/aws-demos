locals {
  bucket_name_long = "${data.aws_caller_identity.current.account_id}-${var.bucket_name}"
}
