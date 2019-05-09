resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-cluster"
}

resource "aws_iam_role" "ecs-execution-role" {
  name = "${var.prefix}-ecs-execution"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ecr-access" {
  name = "${var.prefix}-ecr-access"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-ecr-access" {
  role       = "${aws_iam_role.ecs-execution-role.name}"
  policy_arn = "${aws_iam_policy.ecr-access.arn}"
}

resource "aws_ecr_repository" "payment" {
  name = "${var.prefix}-payment"
}

resource "aws_ecr_repository" "orders" {
  name = "${var.prefix}-orders"
}

resource "aws_ecr_repository" "products" {
  name = "${var.prefix}-products"
}