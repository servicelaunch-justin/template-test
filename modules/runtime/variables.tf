variable "resource_tags" {
  description = "Tags to put on each resource"
}

variable "vpc_id" {
  description = "vpc to deploy in"
}

variable "security_groups_ids" {}

variable "public_subnet_id" {
  description = "Subnet to deploy public host in"
}

variable "private_subnet_ids" {
  description = "Private subnets to deploy worker nodes in"
}

variable "num_workers" {
  description = "number of worker nodes"
  default     = 1
}

variable "num_public" {
  description = "number of public nodes"
  default     = 1
}

variable "lab_ssh_key" {
  description = "env ssh key"
}

variable "private_instance_type" {
  description = "instance type for private instances"
  default     = "t2.2xlarge"
  #default = "t2.micro"
}

variable "public_instance_type" {
  description = "instance type for public instances"
  default     = "t2.micro"
}

variable "aws_key_name" {
  description = "ssh key"
  default     = "leland"
}

variable "aws_region" {
  description = "EC2 Region for the VPC"
  default     = "us-east-2"
}

variable "public_amis" {
  description = "Public AMIs by region"
  default = {
    #https://us-east-2.console.aws.amazon.com/ec2/home?region=us-east-2#LaunchInstanceWizard:ami=ami-04c6b0316264438a5
    us-east-2 = "ami-04c6b0316264438a5"
  }
}

variable "private_amis" {
  description = "Public AMIs by region"
  default = {
    #|  2022-02-22T18:44:59.000Z |  RHEL-7.9_HVM-20220222-x86_64-0-Hourly2-GP2       |  ami-0c1c3220d0b1716d2 |
    #|  2022-05-18T17:29:32.000Z|  RHEL-7.9_HVM-20220512-x86_64-1-Hourly2-GP2  |  ami-0bb2449c2217cb9b0  |
    #|  2020-08-03T17:40:39.000Z |  RHEL-7.8_HVM-20200803-x86_64-0-Hourly2-GP2       |  ami-0514e35fdff0030d9 |
    #aws ec2 describe-images --owners 309956199498 --query 'sort_by(Images, &CreationDate)[*].[CreationDate,Name,ImageId]' --filters "Name=name,Values=RHEL-7*" --region us-east-2 --output table
    #|  2020-11-10T13:14:34.000Z|  CentOS 7.9.2009 x86_64   |  ami-00f8e2c955f7ffa9b  |
    #aws ec2 describe-images --owners 125523088429 --query 'sort_by(Images, &CreationDate)[*].[CreationDate,Name,ImageId]' --filters "Name=name,Values=CentOS 7*" --region us-east-2 --output table
    us-east-2 = "ami-0bb2449c2217cb9b0"
  }
}

