/*
resource "aws_security_group" "allow-ssh" {
  #vpc_id      = aws_vpc.mediawiki_vpc.id
  name        = "demo-allow-ssh"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}*/

resource "aws_vpc" "mediawiki_vpc" {
  cidr_block = "10.0.0.0/16"  # Update the CIDR block as needed

  tags = {
    Name = "my_vpc"
  }
}

resource "aws_subnet" "mediawiki_subnet" {
  vpc_id            = aws_vpc.mediawiki_vpc.id
  cidr_block        = "10.0.1.0/24"  # Update the CIDR block for your subnet
  availability_zone = "ap-south-1a"   # Update the AZ as needed

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_internet_gateway" "mediawiki_igw" {
  vpc_id = aws_vpc.mediawiki_vpc.id

  tags = {
    Name = "my_igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.mediawiki_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mediawiki_igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.mediawiki_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_instance" "auto_instance" {
  ami                     = "ami-013e83f579886baeb"
  instance_type           = "t2.micro"
  subnet_id = aws_subnet.mediawiki_subnet.id
  #vpc_security_group_ids = [aws_security_group.allow-ssh.name]
  associate_public_ip_address = true
  key_name = "keypair_for_burger"
  tags = {
    Name = "mediawiki"
  }
  
}

resource "aws_instance" "bastion" {
  ami                     = "ami-013e83f579886baeb"
  instance_type           = "t2.micro"
  subnet_id = aws_subnet.mediawiki_subnet.id
  #vpc_security_group_ids = [aws_security_group.allow-ssh.name]
  associate_public_ip_address = true
  key_name = "keypair_for_burger"
  tags = {
    Name = "bation"
  }
  
}


resource "null_resource" "cluster" {
  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host        = aws_instance.bastion.public_ip
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./keys/keypair_for_burger.ppk")
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "sleep 2s",
      "sudo yum update; sudo yum install ansible -y",
      "sleep 2s",
      "export ANSIBLE_HOST_KEY_CHECKING=False;",
      "git clone https://github.com/sharan0-0/Saturday.git",
      "sleep 2s",
      "chmod 400 /home/ec2-user/.ssh/*",
      "ansible-playbook Saturday/playbook.yml -i ${aws_instance.auto_instance.private_ip}, -u ec2-user -e 'ansible_python_interpreter=/usr/bin/python3'",
      "sleep 6s"
    ]
    on_failure = continue
  }
}

