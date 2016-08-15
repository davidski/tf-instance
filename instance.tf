provider "aws" {
  profile = "personal"
}

data "template_file" "user_data" {
  template = "${file("templates/user_data.tpl")}"
  vars {
    fs_id = "${var.myfs_id}"
    aws_region = "us-west-2"
  }
}
data "aws_ami" "magnet" {
  most_recent = true
  filter {
    name = "name"
    values = ["niddel*"]
  }
}

resource "aws_spot_instance_request" "magnet-dev" {
  ami           = "${data.aws_ami.magnet.image_id}"
  spot_price    = "${var.myspot_price}"
  spot_type     = "one-time"
  wait_for_fulfillment = true
  instance_type = "r3.2xlarge"
  vpc_security_group_ids = ["${concat(aws_security_group.allow_ssh_from_home.id, mysecurity_groups, aws_security_group.all_outbound.id)}"]
  key_name = "${var.mykey_name}"
  subnet_id = "${var.mysubnet_id}"
  tags = {
    "project" = "niddel"
    "Name"    = "Magnet Dev Server"
  }
  user_data = "${data.template_file.user_data.rendered}"
}

resource "aws_eip" "ip" {
  instance = "${aws_spot_instance_request.magnet-dev.spot_instance_id}"
}

resource "aws_security_group" "allow_ssh_from_home" {
  name = "allow_ssh_from_home"
  description = "Allow SSH from home IP"
  vpc_id = "${var.myvpc_id}"
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["${var.myhome_ip}"]
  }

  tags {
    Name = "allow_ssh_from_home"
  }
}

resource "aws_security_group" "all_outbound" {
  name = "all_outbound"
  description = "Allow all outbound traffic"
  vpc_id = "${var.myvpc_id}"
  egress {
      from_port = 0
      to_port = 0
      protocol = -1
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "all_output"
  }
}

output "ip" {
  value = "${aws_eip.ip.public_ip}"
}