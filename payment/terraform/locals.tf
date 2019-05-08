locals {
  name             = "payment"
  name_with_prefix = "${var.prefix}-${local.name}"
}