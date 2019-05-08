output "endpoint" {
  value = "https://${aws_route53_record.service.fqdn}"
}

output "health-endpoint" {
  value = "https://${aws_route53_record.service.fqdn}/actuator/health"
}

output "example-call-success" {
  value = "curl -s -o /dev/null -w '%{http_code}' -X POST -H 'Content-type: application/json' -d '{\"owner\":\"Tobias Bayer\", \"number\":\"1234567890123456\", \"cvc\": \"123\", \"validTill\": {\"month\":\"10\", \"year\":\"2020\"}}' https://${aws_route53_record.service.fqdn}/validation"
}

output "example-call-failure" {
  value = "curl -s -o /dev/null -w '%{http_code}' -X POST -H 'Content-type: application/json' -d '{\"owner\":\"Tobias Bayer\", \"number\":\"4111\", \"cvc\": \"123\", \"validTill\": {\"month\":\"10\", \"year\":\"2020\"}}' https://${aws_route53_record.service.fqdn}/validation"
}
