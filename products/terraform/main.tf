

resource "aws_cloudwatch_log_group" "service" {
  name              = "/ecs/${var.prefix}/${local.name}"
  retention_in_days = "1"
}

resource "aws_security_group" "global-alb-access" {
  name   = "${local.name_with_prefix}-global-alb-access"
  vpc_id = "${data.aws_vpc.default.id}"

  ingress {
    protocol        = "tcp"
    from_port       = "80"
    to_port         = "80"
    security_groups = ["${data.aws_security_group.global-alb.id}"]
    description     = "global-alb-ingress"
  }

  ingress {
    protocol        = "tcp"
    from_port       = "8080"
    to_port         = "8080"
    security_groups = ["${data.aws_security_group.global-alb.id}"]
    description     = "global-alb-ingress"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "service" {
  name                 = "${local.name_with_prefix}"
  port                 = "8080"
  protocol             = "HTTP"
  vpc_id               = "${data.aws_vpc.default.id}"
  target_type          = "ip"
  deregistration_delay = "30"

  health_check {
    path                = "/actuator/health"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 2
  }
}

resource "aws_lb_listener_rule" "https" {
  listener_arn = "${data.aws_lb_listener.default.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.service.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${local.name_with_prefix}.${var.domain}"]
  }
}

resource "aws_ecs_service" "service" {
  name            = "${local.name}"
  cluster         = "${data.aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.service.arn}"
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = ["${aws_security_group.global-alb-access.id}"]
    subnets          = ["${data.aws_subnet_ids.public.ids}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.service.id}"
    container_name   = "${local.name}"
    container_port   = "8080"
  }
}

data "template_file" "container_definition" {
  template = <<EOF
[
  {
    "name": "${local.name}",
    "image": "853161928370.dkr.ecr.eu-central-1.amazonaws.com/${local.name_with_prefix}:${local.service_version}",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ],
    "environment": [
      {"name":"INFO_APP_VERSION", "value": "${local.service_version}"},
      {"name":"SPRING_DATASOURCE_DRIVERCLASSNAME", "value": "org.postgresql.Driver"},
      {"name":"SPRING_DATASOURCE_URL", "value": "jdbc:postgresql://${aws_db_instance.postgresql.endpoint}/${local.name}?autoReconnect=true"},
      {"name":"SPRING_DATASOURCE_USERNAME", "value": "${lookup(var.postgresql, "user")}"},
      {"name":"SPRING_DATASOURCE_PASSWORD", "value": "${lookup(var.postgresql, "password")}"},
      {"name":"AWS_S3_BUCKET", "value": "${aws_s3_bucket.images.bucket}"},
      {"name":"AWS_S3_REGION", "value": "${aws_s3_bucket.images.region}"},
      {"name":"AWS_S3_PREFIX", "value": "output"}
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.service.name}",
        "awslogs-region": "eu-central-1",
        "awslogs-stream-prefix": "main"
      }
    }
  }
]
EOF
}

// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
resource "aws_ecs_task_definition" "service" {
  family                   = "${local.name}"
  container_definitions    = "${data.template_file.container_definition.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = "${data.aws_iam_role.ecs-execution.arn}"
}

resource "aws_route53_record" "service" {
  name    = "${local.name_with_prefix}.${data.aws_route53_zone.default.name}"
  type    = "A"
  zone_id = "${data.aws_route53_zone.default.id}"

  alias {
    name                   = "${data.aws_lb.global-alb.dns_name}"
    zone_id                = "${data.aws_lb.global-alb.zone_id}"
    evaluate_target_health = true
  }
}
