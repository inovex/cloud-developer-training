data "aws_ecs_cluster" "main" {
  cluster_name = "${var.prefix}-cluster"
}

data "aws_iam_role" "ecs-execution" {
  name = "${var.prefix}-ecs-execution"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "public" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_security_group" "global-alb" {
  name = "Security group for global ALB"
}

data "aws_lb" "global-alb" {
  name = "global-alb"
}

data "aws_lb_listener" "default" {
  load_balancer_arn = "${data.aws_lb.global-alb.arn}"
  port              = 443
}

data "aws_route53_zone" "default" {
  name = "${var.domain}"
}
