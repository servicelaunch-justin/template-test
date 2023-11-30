variable "resource_tags" {
  description = "Tags to put on each resource"
}

variable "public_access_key_file" {
  description = "ssh key on local machine to copy onto bastion host"
}

variable "private_access_key_file" {
  description = "ssh key on local machine used to access bastion host"
}

variable "lab_ssh_key" {
  description = "ssh key generated for lab env"
}

variable "public_subnets_ids" {
  type        = list(any)
  description = "IDs of public subnets to deploy in"
}

variable "security_groups_ids" {
  type        = list(any)
  description = "IDs of security groups to apply"
}

variable "ansible_playbooks" {
  type        = list(any)
}

variable "ansible_inventories" {
  type        = list(any)
}