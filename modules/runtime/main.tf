
resource "aws_key_pair" "access_key" {
  key_name   = "ssh_key"
  public_key = var.lab_ssh_key.public_key_openssh
}

/*
  Public Server(s)
*/

resource "aws_instance" "public-nodes" {
  ami = lookup(var.public_amis, var.aws_region)

  instance_type               = var.public_instance_type
  key_name                    = aws_key_pair.access_key.id
  vpc_security_group_ids      = var.security_groups_ids
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true
  source_dest_check           = false
  #user_data                   = data.cloudinit_config.server_config_public.rendered

  tags = merge({
    Name = "runtime-public-node"
  }, var.resource_tags)

}

/*
  Private Servers 
*/

resource "aws_instance" "worker-nodes" {
  count     = var.num_workers
  subnet_id = element(var.private_subnet_ids, count.index % length(var.private_subnet_ids))

  ami                    = lookup(var.private_amis, var.aws_region)
  instance_type          = var.private_instance_type
  key_name               = aws_key_pair.access_key.id
  vpc_security_group_ids = var.security_groups_ids #["${aws_security_group.private.id}"]

  source_dest_check = false
  #user_data            = data.cloudinit_config.server_config_worker.rendered
  iam_instance_profile = aws_iam_instance_profile.describe_ec2.name

  root_block_device {
    volume_size           = 512
    volume_type           = "standard"
    delete_on_termination = true
  }
  ebs_block_device {
    device_name           = "/dev/sdz"
    volume_size           = 256
    volume_type           = "standard"
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/sdy"
    volume_size           = 256
    volume_type           = "standard"
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/sdx"
    volume_size           = 256
    volume_type           = "standard"
    delete_on_termination = true
  }

  tags = merge({
    Name    = "runtime-worker-node-${count.index}"
    Role    = "main"
    Cluster = "bluedata"
  }, var.resource_tags)
}