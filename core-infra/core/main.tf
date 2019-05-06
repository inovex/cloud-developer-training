resource "aws_route53_zone" "main" {
  name = "${var.domain_name}"
}

resource "aws_security_group" "global-alb" {
  name   = "Security group for global ALB"
  vpc_id = "${data.aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "global-alb" {
  name = "global-alb"
  internal = false

  subnets            = ["${data.aws_subnet_ids.public.ids}"]
  security_groups = ["${aws_security_group.global-alb.id}"]
}

resource "aws_lb_target_group" "default-http" {
  name     = "global-alb-HTTP-default"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.default.id}"
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = "${aws_lb.global-alb.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "default-https" {
  name     = "global-alb-HTTPS-default"
  port     = 443
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.default.id}"
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = "${aws_lb.global-alb.id}"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "${aws_acm_certificate.main.arn}"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Hello cloud developer trainees :)"
      status_code  = "200"
    }
  }
}

resource "aws_route53_record" "status" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "status.${aws_route53_zone.main.name}"
  type    = "A"

  alias {
    name                   = "${aws_lb.global-alb.dns_name}"
    zone_id                = "${aws_lb.global-alb.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "main" {
  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "main" {
  name    = "${aws_acm_certificate.main.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.main.domain_validation_options.0.resource_record_type}"
  zone_id = "${aws_route53_zone.main.id}"
  records = ["${aws_acm_certificate.main.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = "${aws_acm_certificate.main.arn}"
  validation_record_fqdns = ["${aws_route53_record.main.fqdn}"]
}