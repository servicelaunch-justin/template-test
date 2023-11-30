example usage:

module "app_hosts" {
  depends_on = [ module.networking  ]
  source = "./modules/host"
  resource_tags = var.resource_tags

  group_name = "test-group"
  subnet_ids = module.networking.public_subnets_id
  num_hosts = 1
  lab_ssh_key         = tls_private_key.labkey
  security_groups_ids = module.networking.security_groups_ids

  roles = ["harbor"]
  var_files = ["harbor.yaml"]
}