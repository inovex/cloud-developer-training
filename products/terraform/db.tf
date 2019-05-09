resource "aws_security_group" "postgresql" {
  name = "${local.name_with_prefix}-postgresql"

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
  identifier              = "${local.name_with_prefix}-db"
  instance_class          = "db.t2.micro"
  storage_type            = "gp2"
  name                    = "${local.name}"
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