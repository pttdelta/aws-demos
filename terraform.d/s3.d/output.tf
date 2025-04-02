output "data_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "data_caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "data_caller_user" {
  value = data.aws_caller_identity.current.user_id
}

output "local_bucket_name_long" {
  value =  "${local.bucket_name_long}"
}
