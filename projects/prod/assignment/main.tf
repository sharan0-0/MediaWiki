#the main.tf file
data "aws_subnet_ids" "subnet" {
  vpc_id = module.vpc.vpc_id
  tags = {
    Type = "public"
  }
}

resource "null_resource" "cluster" {
  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host        = module.bastion.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("../../../keys/id_rsa")
  }

  provisioner "file" {
    source      = "../../../keys/id_rsa"
    destination = "~/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "sleep 10s",
      "sudo yum update; sudo yum install ansible -y",
      "sleep 10s",
      "export ANSIBLE_HOST_KEY_CHECKING=False;",
      "git clone https://github.com/YashDevops/Assignment.git",
      "sleep 10s",
      "chmod 400 /home/ubuntu/.ssh/id_rsa",
      "ansible-playbook Assignment/Ansible/MediaWiki/playbooks/release.yml -i ${module.ec2.private_ip}, -u ubuntu -e 'ansible_python_interpreter=/usr/bin/python3'",
      "sleep 60s"
    ]
    on_failure = continue
  }
}

module "vpc" {
  source        = "../../../modules/vpc"
  Name          = var.Name
  BussinessUnit = var.BussinessUnit
  Team          = var.Team
  Project       = var.Project
}

module "key" {
  source             = "../../../modules/keys"
  key_name           = "mediawiki-keys"
  PATH_TO_PUBLIC_KEY = "../../../keys/id_rsa.pub"
}

module "ec2" {
  source        = "../../../modules/ec2"
  account_id    = ["099720109477"]
  vpc_id        = module.vpc.vpc_id
  sub_id        = module.vpc.private_1a
  ssh_key       = module.key.key_name
  Name          = var.Name
  BussinessUnit = var.BussinessUnit
  Team          = var.Team
  Project       = var.Project
}

module "bastion" {
  source        = "../../../modules/ec2"
  account_id    = [var.account_id]
  vpc_id        = module.vpc.vpc_id
  sub_id        = module.vpc.public_1a
  ssh_key       = module.key.key_name
  Name          = "${var.Name}-bastion"
  BussinessUnit = var.BussinessUnit
  Team          = var.Team
  Project       = var.Project
}

module "alb" {
  source                  = "../../../modules/alb"
  port                    = "80"
  protocol                = "HTTP"
  health_check_intervals  = "5"
  health_check_path       = "/"
  health_check_protocol   = "HTTP"
  health_check_timeout    = "3"
  healthy_threshold       = "2"
  unhealthy_threshold     = "3"
  listner_port            = "80"
  listner_protocol        = "HTTP"
  attached_instance_count = "1"
  Name                    = var.Name
  vpc_id                  = module.vpc.vpc_id
  subnets                 = data.aws_subnet_ids.subnet.ids
  target_ids              = module.ec2.instance_id
}


# module "ebs" {
#   source = "../../../modules/ebs"
#   availability_zone = module.vpc.private_1a_subnet
#   instance_id = module.ec2.instance_id
#   size = 40
#   device_name = "/dev/xvdb"
# }
