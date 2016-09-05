provider "aws" {
  profile = "personal"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user_data.tpl")}"
  vars {
    fs_id = "${var.myfs_id}"
  }
}

data "aws_ami" "ami" {
  most_recent = true
  filter {
    name = "name"
    values = ["niddel*"]
  }
}

resource "aws_iam_instance_profile" "profile" {
    name_prefix = "NiddelInstanceProfile"
    roles = ["${var.role_names}"]
}

/*
resource "aws_spot_instance_request" "spot_request" {
  ami                         = "${data.aws_ami.ami.image_id}"
  spot_price                  = "${var.myspot_price}"
  spot_type                   = "one-time"
  wait_for_fulfillment        = true
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.profile.name}"
  instance_type               = "${var.myinstance_type}"
  vpc_security_group_ids      = ["${aws_security_group.allow_ssh_from_home.id}", "${var.mysecurity_groups}", "${aws_security_group.all_outbound.id}"]
  key_name                    = "${var.mykey_name}"
  subnet_id                   = "${var.mysubnet_id}"
  tags = {
    "project" = "niddel"
    "Name"    = "Magnet Dev Server"
  }
  user_data = "${data.template_file.user_data.rendered}"
}
*/

resource "aws_instance" "instance" {
  ami                         = "${data.aws_ami.ami.image_id}"
  associate_public_ip_address = true
  instance_type               = "${var.myinstance_type}"
  iam_instance_profile        = "${aws_iam_instance_profile.profile.name}"
  vpc_security_group_ids      = ["${aws_security_group.allow_ssh_from_home.id}", "${var.mysecurity_groups}", "${aws_security_group.all_outbound.id}"]
  key_name                    = "${var.mykey_name}"
  subnet_id                   = "${var.mysubnet_id}"
  tags = {
    "project" = "niddel"
    "Name"    = "Magnet Dev Server"
  }
  user_data = "${data.template_file.user_data.rendered}"
}

resource "aws_route53_record" "dns" {
  zone_id       = "${var.zone_id}"
  name          = "${var.name}"
  type          = "A"
  ttl           = "60"
  records       = ["${aws_instance.instance.public_ip}"]
}

resource "aws_security_group" "allow_ssh_from_home" {
  name_prefix = "allow_ssh_from_home_"
  vpc_id = "${var.myvpc_id}"
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["${var.myhome_ip}/32"]
  }

  tags {
    Name = "allow_ssh_from_home"
  }
}

resource "aws_security_group" "all_outbound" {
  name_prefix = "all_outbound_"
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

/*
output "fqdn" {
  value = "${aws_route53_record.dns.fqdn}"
}
*/