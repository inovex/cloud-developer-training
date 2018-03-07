output "elb-endpoint" {
  value = "${aws_elb.whiskystore-orders-elb.dns_name}"
}

output "db" {
  value = "${aws_db_instance.postgresql.endpoint}"
}

