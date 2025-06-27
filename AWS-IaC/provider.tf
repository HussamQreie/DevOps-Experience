# CSP
terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

# Workspace Region
provider "aws" {
  region = "eu-central-1"
}