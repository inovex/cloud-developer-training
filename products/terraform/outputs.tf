output "images-s3-bucket" {
  value = "${aws_s3_bucket.images.bucket}"
}

output "elb-endpoint" {
  value = "${aws_elb.whiskystore-products-elb.dns_name}"
}

output "example-call" {
  value = "curl http://${aws_elb.whiskystore-products-elb.dns_name}/products"
}

output "db" {
  value = "${aws_db_instance.postgresql.endpoint}"
}