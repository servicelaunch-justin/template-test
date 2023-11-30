#!/bin/bash
sudo apt-get update -y &&
sudo apt-get install -y \
apt-transport-https \
ca-certificates \
curl \ 
gnupg-agent \ 
software-properties-common \
ec2-instance-connect &&
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&
sudo apt-add-repository ppa:ansible/ansible &&
sudo apt-get udpate -y &&
sudo apt-get install docker-ce docker-ce-cli containerd.io -y &&
sudo usermod -aG docker ubuntu &&
sudo apt install ansible &&
chmod 0600 ~/.ssh/id_rsa