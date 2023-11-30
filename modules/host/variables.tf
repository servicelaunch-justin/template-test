variable "resource_tags" {
  description = "Tags to put on each resource"
}

variable "lab_ssh_key" {
  description = "env ssh key"
}

variable "security_groups_ids" {
  type        = list(any)
  description = "IDs of security groups to apply"
}

variable "group_name" { }


variable "instance_type" {
  default = "t2.micro"
}

variable "num_hosts" {
  default = 1
}

variable "subnet_ids" { 
  type        = list(any)
  description = "IDs of subnets to distribute hosts into"
}

variable "block_devices" { 
  default = null
}

variable root_block {
  default = {
    volume_size           = 512
    volume_type           = "standard"
    delete_on_termination = true
  }
}

//Ansible Variables

variable "roles" { }

variable "var_files" {
  default = null
}