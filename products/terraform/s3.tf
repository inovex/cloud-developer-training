resource "aws_s3_bucket" "images" {
  bucket = "${var.prefix}-whiskystore-images"
  acl = "public-read-write"
}