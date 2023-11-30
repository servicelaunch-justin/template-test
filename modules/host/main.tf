resource "aws_key_pair" "access_key" {
  key_name   = "access_key"
  public_key = var.lab_ssh_key.public_key_openssh
}

resource "aws_instance" "host" {
  count                       = var.num_hosts
  instance_type               = var.instance_type
  ami                         = data.aws_ami.rhel-88-useast2.id
  #ami                         = data.aws_ami.ubuntu.id
  key_name                    = aws_key_pair.access_key.id
  #key_name                    = var.lab_ssh_key.id
  vpc_security_group_ids      = var.security_groups_ids
  subnet_id                   = element(var.subnet_ids, count.index % length(var.subnet_ids))
  user_data                   = file("${path.module}/templates/userdata.tpl")
  tags = merge({
    Name = "${var.group_name}${count.index}"
  }, var.resource_tags)

  root_block_device {
    volume_type = var.root_block.volume_type
    volume_size = var.root_block.volume_size
    delete_on_termination = var.root_block.delete_on_termination
  }

  dynamic ebs_block_device {
    for_each = var.block_devices != null ? toset(var.block_devices) : []
    content {
      device_name           = block_devices.value["device_name"]
      volume_size           = block_devices.value["volume_size"]
      volume_type           = block_devices.value["volume_type"]
      delete_on_termination = block_devices.value["delete_on_termination"]
    }
  }

}