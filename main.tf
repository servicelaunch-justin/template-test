/*====
Create Key Pair for inside environment
====*/
resource "tls_private_key" "labkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "labkey"
  public_key = tls_private_key.labkey.public_key_openssh
}


/*====
Create VPC and Subnets
======*/

module "networking" {
  source = "./modules/networking"

  resource_tags        = var.resource_tags
  region               = var.region
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zones   = var.availability_zones
}

/*====
Create public subnet instace to access private networks
and run ansible playbooks
======*/
/*
module "bastion_hosts" {
  depends_on    = [module.networking, aws_key_pair.generated_key, module.control_node]
  source        = "./modules/bastion"
  resource_tags = var.resource_tags

  public_subnets_ids      = module.networking.public_subnets_id
  security_groups_ids     = module.networking.security_groups_ids
  lab_ssh_key             = tls_private_key.labkey
  public_access_key_file  = var.public_access_key_file
  private_access_key_file = var.private_access_key_file

  ansible_inventories     = [module.control_node.inventory]
  ansible_playbooks       = [module.control_node.playbook]

}

output "bastion_host" {
  value = module.bastion_hosts.host_ips
}*/

/*=====
App Hosts
=====*/
/*
module "app_hosts" {
  depends_on    = [module.networking]
  source        = "./modules/host"
  resource_tags = var.resource_tags

  group_name          = "harbor-repo"
  subnet_ids          = module.networking.public_subnets_id
  num_hosts           = 1
  lab_ssh_key         = tls_private_key.labkey
  security_groups_ids = module.networking.security_groups_ids

  roles     = ["harbor"]
  var_files = ["harbor.yaml"]


}*/
/*
module "app_hosts" {
  depends_on    = [module.networking]
  source        = "./modules/host"
  resource_tags = var.resource_tags

  group_name          = "rhel_host"
  subnet_ids          = module.networking.private_subnets_id
  num_hosts           = 1
  lab_ssh_key         = tls_private_key.labkey
  security_groups_ids = module.networking.security_groups_ids
  instance_type       = "t2.medium"

  roles     = ["mysql"]
  var_files = ["rhel_mysql.yaml"]


}*/

/*
module "worker_nodes" {
  depends_on    = [module.networking]
  source        = "./modules/host"
  resource_tags = var.resource_tags

  group_name          = "worker_nodes"
  subnet_ids          = module.networking.public_subnets_id
  num_hosts           = 3
  lab_ssh_key         = tls_private_key.labkey
  security_groups_ids = module.networking.security_groups_ids
  instance_type       = "t2.medium"

  roles     = []
  var_files = []


}*/

/*
module "control_node" {
  depends_on    = [module.networking]
  source        = "./modules/host"
  resource_tags = var.resource_tags

  group_name          = "control_nodes"
  subnet_ids          = module.networking.public_subnets_id
  num_hosts           = 3
  lab_ssh_key         = tls_private_key.labkey
  security_groups_ids = module.networking.security_groups_ids
  instance_type       = "t2.medium"

  roles     = ["docker"]
  var_files = ["docker.yaml"]


}*/

/*
Runtime
*/
/*
module "runtime" {
  depends_on    = [module.networking]
  source        = "./modules/runtime"
  resource_tags = var.resource_tags

  aws_region          = "us-east-2"
  vpc_id              = module.networking.vpc_id
  security_groups_ids = module.networking.security_groups_ids
  public_subnet_id    = module.networking.public_subnets_id[0]
  private_subnet_ids  = module.networking.private_subnets_id
  num_workers         = 3
  num_public          = 1
  lab_ssh_key         = tls_private_key.labkey
} */