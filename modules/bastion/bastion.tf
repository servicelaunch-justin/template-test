data "aws_ami" "ubuntu" {
  owners = null
  filter {
    name = "image-id"
    values = ["ami-024e6efaf93d85776"]
  }

}

resource "aws_key_pair" "access_key" {
  key_name   = "bastion_access"
  public_key = file(var.public_access_key_file)

}

resource "aws_instance" "bastion_host" {

  count                       = length(var.public_subnets_ids)
  instance_type               = "t2.micro"
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = aws_key_pair.access_key.id
  vpc_security_group_ids      = var.security_groups_ids
  subnet_id                   = element(var.public_subnets_ids, count.index)
  user_data                   = templatefile("${path.module}/templates/userdata.tpl", {host_number = count.index})
  associate_public_ip_address = true
  tags = merge({
    Name = "bastion-host-${element(var.public_subnets_ids, count.index)}"
  }, var.resource_tags)

  root_block_device {
    volume_type = "standard"
    volume_size = 10
  }

  provisioner "remote-exec" {
    inline = ["echo 'Hello World'"]
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.private_access_key_file)
    }
  }

  # use remote exec first, otherwise local-exec will attempt to run as soon
  # as machine is created, before ssh and other processes start and the 
  # command will fail. Remote exec will ensure ssh is up and listening

  #Copy lab private key 
  provisioner "file" {
    content     = var.lab_ssh_key.private_key_pem
    destination = "/home/ubuntu/.ssh/id_rsa"
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.private_access_key_file)
    }
  }

  #Copy Public Keys for Other Users
  provisioner "file" {
    content     = "${path.module}/public_keys"
    destination = "/home/ubuntu/public_keys"
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.private_access_key_file)
    }
  }
 
  #Copy Ansible Source Files
  provisioner "file" {
    source = "${path.root}/ansible"
    destination = "/home/ubuntu/ansible"
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.private_access_key_file)
    }
  }
  
  #Copy App Configs 
  provisioner "file" {
    source = "${path.root}/app_configs/"
    destination = "/home/ubuntu/ansible/var_files"
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.private_access_key_file)
    }
  }

  #Create Ansible Playbook
  provisioner "file" {
    content     = templatefile("${path.module}/templates/ansible_playbook.tpl", { playbooks = var.ansible_playbooks })
    destination = "/home/ubuntu/ansible/playbook.yaml"
    #destination = "/opt/ansible/playbook.yaml"
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.private_access_key_file)
    }
  }

  #Create Ansible Inventory File
  provisioner "file" {
    content = templatefile("${path.module}/templates/ansible_inventory.tpl", { inventories = merge(var.ansible_inventories...) })
    #destination = "/opt/ansible/inventory.ini"
    destination = "/home/ubuntu/ansible/inventory.ini"
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.private_access_key_file)
    }
  }

  #mv ansible directory
  provisioner "remote-exec" {
    inline = ["sudo mv /home/ubuntu/ansible /opt/"]
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.private_access_key_file)
    }
  }

  #mv and chmod keys
  provisioner "remote-exec" {
    inline = ["mv /home/ubuntu/public_keys/* /home/ubuntu/.ssh", "chmod 0600 ~/.ssh/*"]
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.private_access_key_file)
    }
  }

  #install deps and run playbook
  provisioner "remote-exec" {
    inline = ["sudo add-apt-repository -y universe", "sudo apt-get update -y", 
      "sudo apt-get install -y --force-yes apt-transport-https  ca-certificates curl gnupg-agent software-properties-common",
      "sudo apt-get install -y --assume-yes python3-pip",
      "python3 -m pip install --user ansible", 
      "export PATH=/home/ubuntu/.local/bin:$PATH", 
      "cd /opt/ansible && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook playbook.yaml -i inventory.ini" ]
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.private_access_key_file)
    }
  }
  
}