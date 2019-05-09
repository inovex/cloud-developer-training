locals {
  name             = "products"
  name_with_prefix = "${var.prefix}-${local.name}"
}