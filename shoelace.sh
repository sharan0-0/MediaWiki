#!/bin/bash
sleep 10s
sudo yum update; sudo yum install ansible -y
sleep 10s
export ANSIBLE_HOST_KEY_CHECKING=False
git clone https://github.com/sharan0-0/Tuesday.git
sleep 10s
chmod 400 /home/ubuntu/.ssh/id_rsa
ansible-playbook ./Tuesday/tf_ans/Ansible/MediaWiki/release.yml -i localhost -u ec2-user -e 'ansible_python_interpreter=/usr/bin/python3'
sleep 60s