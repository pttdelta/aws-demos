variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-west-2"
}

variable "eks_name" {
  description = "EKS name"
  type        = string
  default     = "deidre"
}

variable "env" {
  description = "Target environment"
  type        = string
  default     = "dev"
}
