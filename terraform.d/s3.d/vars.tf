variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-west-2"
}

variable "bucket_name" {
  description = "Bucket name"
  type        = string
  default     = "hyacinth"
}

variable "env" {
  description = "Target environment"
  type        = string
  default     = "dev"
}
