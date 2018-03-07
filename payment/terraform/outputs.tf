output "elb-endpoint" {
  value = "${aws_elb.whiskystore-payment-elb.dns_name}"
}

output "example-call-success" {
  value = "curl -s -o /dev/null -w '%{http_code}' -X POST -H 'Content-type: application/json' -d '{\"owner\":\"Tobias Bayer\", \"number\":\"4111111111111111\", \"validTill\": {\"month\":\"10\", \"year\":\"2020\"}}' http://${aws_elb.whiskystore-payment-elb.dns_name}/validation"
}

output "example-call-failure" {
  value = "curl -s -o /dev/null -w '%{http_code}' -X POST -H 'Content-type: application/json' -d '{\"owner\":\"Tobias Bayer\", \"number\":\"4111111111111111111\", \"validTill\": {\"month\":\"10\", \"year\":\"2020\"}}' http://${aws_elb.whiskystore-payment-elb.dns_name}/validation"
}