terraform {
  required_version = "=1.11.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.94.0"  # Replace with the version you want
    }
  }

  backend "local" {
    path = "/home/andy/TERRAFORM-STATE/aws-demos/eks-dev.tfstate"
  }
}

