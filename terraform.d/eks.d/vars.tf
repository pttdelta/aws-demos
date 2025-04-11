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

variable "eks_cluster_version" {
  description = "Version of EKS cluster"
  type        = string
  default     = "1.32"
}

# TODO - address this apparently absent variable 
# tflint-ignore: terraform_unused_declarations
variable "enable_cluster_creator_admin_permissions" {
  description = "Indicates whether or not to add the cluster creator (the identity used by Terraform) as an administrator via access entry"
  type        = bool
  default     = true
}
