terraform {
  backend "s3" {
    region = "eu-central-1"
    bucket = "javaland-whiskystore-terraform"
    key = "payment.json"
    profile = "javaland"
    workspace_key_prefix = "javaland"
  }
}

provider "aws" {
  region = "eu-central-1"
  profile = "javaland"
  version = "~> 1.9"
}

provider "template" {
  version = "~> 1.0"
}

resource "aws_key_pair" "ssh" {
  key_name   = "${var.prefix}-javaland-payment"
  public_key = "${file("ssh/javaland.pub")}"
}

// --- EC2 ---

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "provision_script" {
  template = "${file("provision_instance.sh")}"

  vars {
    bucket = "s3://javaland-whiskystore-terraform"
    prefix = "${var.prefix}/jars/payment"
    jar = "payment-0.0.1-SNAPSHOT.jar" // This would usually be passed as a variable
  }
}

resource "aws_security_group" "whiskystore-payment" {
  name = "${var.prefix}-whiskystore-payment"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "whiskystore-payment" {
  name_prefix = "${var.prefix}-whiskystore-payment Launch Configuration"
  image_id = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.whiskystore-payment.id}"]
  key_name = "${aws_key_pair.ssh.id}"
  iam_instance_profile = "EC2Service"
  enable_monitoring = false

  user_data = "${data.template_file.provision_script.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

// --- ELB (Load Balancing) ---

resource "aws_security_group" "whiskystore-payment-elb" {
  name = "${var.prefix}-whiskystore-payment-elb"

  # HTTP access from anywhere
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "whiskystore-payment-elb" {
  name = "${var.prefix}-payment-elb"
  cross_zone_load_balancing = true

  security_groups = ["${aws_security_group.whiskystore-payment-elb.id}"]
  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 3
    timeout = 2
    target = "HTTP:8080/health"
    interval = 10
  }

  tags {
    Name = "${var.prefix}-whiskystore-payment"
  }
}

// --- Auto-scaling ---

resource "aws_autoscaling_group" "whiskystore-payment" {
  name = "${var.prefix}-whiskystore-payment"
  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

  launch_configuration = "${aws_launch_configuration.whiskystore-payment.id}"
  load_balancers = ["${aws_elb.whiskystore-payment-elb.name}"]
  termination_policies = ["OldestInstance"]

  min_size = "1"
  max_size = "2"
  desired_capacity = "1"

  tag {
    key = "Name"
    value = "${var.prefix}-whiskystore-payment"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

