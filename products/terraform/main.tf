terraform {
  backend "s3" {
    region = "eu-central-1"
    bucket = "javaland-whiskystore-terraform"
    key = "products.json"
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
  key_name   = "${var.prefix}-javaland-products"
  public_key = "${file("ssh/javaland.pub")}"
}

// --- S3 ---

resource "aws_s3_bucket" "images" {
  bucket = "${var.prefix}-whiskystore-images"
  acl = "public-read-write"
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
    prefix = "${var.prefix}/jars/products"
    jar = "products-0.0.1-SNAPSHOT.jar" // This would usually be passed as a variable
    images_bucket = "${aws_s3_bucket.images.bucket}"
    images_bucket_region = "${aws_s3_bucket.images.region}"
    images_bucket_prefix = "output"
    db_endpoint = "${aws_db_instance.postgresql.endpoint}"
    db_user = "${aws_db_instance.postgresql.username}"
    db_password = "${aws_db_instance.postgresql.password}"
  }
}

resource "aws_security_group" "whiskystore-products" {
  name = "${var.prefix}-whiskystore-products"

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

resource "aws_launch_configuration" "whiskystore-products" {
  name_prefix = "${var.prefix}-whiskystore-products Launch Configuration"
  image_id = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.whiskystore-products.id}"]
  key_name = "${aws_key_pair.ssh.id}"
  iam_instance_profile = "EC2Service"
  enable_monitoring = false

  user_data = "${data.template_file.provision_script.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

// --- ELB (Load Balancing) ---

resource "aws_security_group" "whiskystore-products-elb" {
  name = "${var.prefix}-whiskystore-products-elb"

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

resource "aws_elb" "whiskystore-products-elb" {
  name = "${var.prefix}-products-elb"
  cross_zone_load_balancing = true

  security_groups = ["${aws_security_group.whiskystore-products-elb.id}"]
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
    Name = "${var.prefix}-whiskystore-products"
  }
}

// --- Auto-scaling ---

resource "aws_autoscaling_group" "whiskystore-products" {
  name = "${var.prefix}-whiskystore-products"
  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

  launch_configuration = "${aws_launch_configuration.whiskystore-products.id}"
  load_balancers = ["${aws_elb.whiskystore-products-elb.name}"]
  termination_policies = ["OldestInstance"]

  min_size = "1"
  max_size = "2"
  desired_capacity = "1"

  tag {
    key = "Name"
    value = "${var.prefix}-whiskystore-products"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

// --- DATABASE ---

resource "aws_security_group" "postgresql" {
  name = "${var.prefix}-postgresql-products"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ] # NOT RECOMMENDED FOR PRODUCTION!
  }
}

resource "aws_db_instance" "postgresql" {
  allocated_storage       = "5"
  engine                  = "postgres"
  engine_version          = "9.6.5"
  identifier              = "${var.prefix}-products-db"
  instance_class          = "db.t2.micro"
  storage_type            = "gp2"
  name                    = "products"
  username                = "${lookup(var.postgresql, "user")}"
  password                = "${lookup(var.postgresql, "password")}"
  backup_window           = "03:00-03:30"
  maintenance_window      = "Mon:04:00-Mon:04:30"
  multi_az                = false
  port                    = "5432"
  skip_final_snapshot     = true
  backup_retention_period = 0
  vpc_security_group_ids  = [ "${aws_security_group.postgresql.id}" ]
}
