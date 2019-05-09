output "endpoint" {
  value = "https://${aws_route53_record.service.fqdn}"
}

output "health-endpoint" {
  value = "https://${aws_route53_record.service.fqdn}/actuator/health"
}

output "db" {
  value = "${aws_db_instance.postgresql.endpoint}"
}