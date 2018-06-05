/*
terraform {
  required_version = "> 0.11.7"
}
*/

provider "aws" {
  access_key = "AKIAIT52YAQ7OMTAZPKQ"
  secret_key = "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"
  region     = "us-east-2"
}

resource "aws_vpc" "challenge-vpc" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.challenge-vpc.id}"
}

resource "aws_subnet" "challenge-net1" {
  vpc_id                  = "${aws_vpc.challenge-vpc.id}"
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags {
    Name = "public subnet 1"
  }
}

resource "aws_subnet" "challenge-net2" {
  vpc_id                  = "${aws_vpc.challenge-vpc.id}"
  cidr_block              = "192.168.2.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true

  tags {
    Name = "public subnet 2"
  }
}

resource "aws_subnet" "challenge-net3" {
  vpc_id            = "${aws_vpc.challenge-vpc.id}"
  cidr_block        = "192.168.3.0/24"
  availability_zone = "us-east-2c"

  tags {
    Name = "private subnet 1"
  }
}

resource "aws_route_table" "rtb" {
  vpc_id = "${aws_vpc.challenge-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "rtb-challenge"
  }
}

resource "aws_main_route_table_association" "mainrtb" {
  vpc_id         = "${aws_vpc.challenge-vpc.id}"
  route_table_id = "${aws_route_table.rtb.id}"
}

resource "aws_route_table_association" "rtb-net1" {
  subnet_id      = "${aws_subnet.challenge-net1.id}"
  route_table_id = "${aws_route_table.rtb.id}"
}

resource "aws_route_table_association" "rtb-net2" {
  subnet_id      = "${aws_subnet.challenge-net2.id}"
  route_table_id = "${aws_route_table.rtb.id}"
}

//comment if network will be private
resource "aws_route_table_association" "rtb-net3" {
  subnet_id      = "${aws_subnet.challenge-net3.id}"
  route_table_id = "${aws_route_table.rtb.id}"
}

/*
resource "aws_lb" "jenkins_lb" {
  name               = "jenkins-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.public.*.id}"]

  enable_deletion_protection = true

  tags {
    Environment = "production"
  }
}
*/
resource "aws_instance" "jenkins" {
  ami                         = "ami-922914f7"
  instance_type               = "t2.small"
  key_name                    = "cloudmaster"
  subnet_id                   = "${aws_subnet.challenge-net1.id}"
  vpc_security_group_ids      = ["${aws_security_group.worker-sg.id}"]
  associate_public_ip_address = true

  tags {
    Name = "jenkins"
  }

  root_block_device {
    volume_size = "30"
  }

  provisioner "remote-exec" {
    inline = ["sudo yum -y update"]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file(var.ssh_key_private)}"
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${self.public_ip},' -t jenkins --become --private-key ${var.ssh_key_private} playbook.yml"
  }
}

/*
resource "aws_route53_zone" "primary" {
  name = "cloudmaster.cr"
}
*/
/*
resource "aws_route53_record" "jenkins" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "cloudmaster.cr"
  type    = "CNAME"

  alias {
    name                   = "${aws_lb.jenkins-lb.dns_name}"
    zone_id                = "${aws_lb.jenkins-lb.zone_id}"
    evaluate_target_health = false
  }
}
*/
resource "aws_instance" "mongodb" {
  ami                         = "ami-922914f7"
  instance_type               = "t2.micro"
  key_name                    = "cloudmaster"
  subnet_id                   = "${aws_subnet.challenge-net3.id}"
  vpc_security_group_ids      = ["${aws_security_group.database-sg.id}"]
  associate_public_ip_address = true

  tags {
    Name = "mongodb"
  }

  provisioner "remote-exec" {
    inline = ["sudo yum -y update"]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file(var.ssh_key_private)}"
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${self.public_ip},' -t mongodb --become --private-key ${var.ssh_key_private} playbook.yml"
  }
}

resource "aws_instance" "kube-master" {
  ami = "ami-03291866"

  // used to be t2.micro, but never worked 
  instance_type               = "t2.small"
  key_name                    = "cloudmaster"
  subnet_id                   = "${aws_subnet.challenge-net1.id}"
  vpc_security_group_ids      = ["${aws_security_group.worker-sg.id}"]
  associate_public_ip_address = true
  private_ip                  = "${var.k8s_master_ip}"

  tags {
    Name = "kube-master"
  }

  provisioner "remote-exec" {
    inline = ["sudo yum -y update"]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file(var.ssh_key_private)}"
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${self.public_ip},' -t k8s-master -e k8s_master_ip=${var.k8s_master_ip} --become --private-key ${var.ssh_key_private} playbook.yml"
  }
}

resource "aws_instance" "kube-worker" {
  count = 2
  ami   = "ami-03291866"

  // used to be t2.micro, but never worked 
  instance_type               = "t2.small"
  key_name                    = "cloudmaster"
  subnet_id                   = "${aws_subnet.challenge-net2.id}"
  vpc_security_group_ids      = ["${aws_security_group.worker-sg.id}"]
  associate_public_ip_address = true
  depends_on                  = ["aws_instance.kube-master"]

  tags {
    Name = "kube-worker${count.index}"
  }

  provisioner "remote-exec" {
    inline = ["sudo yum -y update"]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file(var.ssh_key_private)}"
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${self.public_ip},' -t k8s-worker -e k8s_master_ip=${var.k8s_master_ip} --become --private-key ${var.ssh_key_private} playbook.yml"
  }
}

resource "aws_security_group" "worker-sg" {
  name        = "worker-sg"
  description = "Allow web and ssh inbound traffic"
  vpc_id      = "${aws_vpc.challenge-vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.challenge-vpc.cidr_block}"]
  }

  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10250
    to_port     = 10255
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

    //prefix_list_ids = ["pl-12c4e678"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "database-sg" {
  name        = "database-sg"
  description = "Allow database inbound traffic"
  vpc_id      = "${aws_vpc.challenge-vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

    //prefix_list_ids = ["pl-12c4e678"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
