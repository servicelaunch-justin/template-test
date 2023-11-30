variable "resource_tags" {
  type = map(string)
}

variable "public_access_key_file" {
  description = "ssh key on local machine to copy onto bastion host"
}

variable "private_access_key_file" {
  description = "ssh key on local machine used to access bastion host"
}

//Networking
variable "region" {
  description = "AWS Deployment region.."
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
}

variable "availability_zones" {
  type        = list(any)
  description = "The az that the resources will be launched"
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
}


