#!/bin/bash
touch /home/ubuntu/testfile && \
sudo apt-get update -y && \ 
sudo apt-get install -y \
apt-transport-https \
ca-certificates \
curl \ 
gnupg-agent \ 
software-properties-common \ 
python3-pip && \
python3 -m pip install --user ansible && \ 
export PATH=/home/ubuntu/.local/bin:$PATH && \ 
cd /opt/ansible && \
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook playbook.yaml -i inventory.ini

#ansible-playbook --private-key ~/.ssh/labkey main.yaml
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
#sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" &&
#sudo apt-add-repository ppa:ansible/ansible &&
#sudo apt-get udpate -y &&
#sudo apt-get install docker-ce docker-ce-cli containerd.io -y &&
#sudo usermod -aG docker ubuntu &&
#sudo apt install ansible &&
#cd /opt/ansible && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook playbook.yaml -i inventory.ini