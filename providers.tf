terraform {
  cloud {
    organization = "servicelaunch-devops"

    workspaces {
      name = "tf-cloud-testing"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    cloudinit-config = {
      source  = "hashicorp/cloudinit"
      version = "2.2.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}

