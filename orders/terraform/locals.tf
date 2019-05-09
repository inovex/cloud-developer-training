locals {
  name             = "orders"
  name_with_prefix = "${var.prefix}-${local.name}"

  service_version = "${var.version == "UNSET" ? trimspace(file("../VERSION")) : var.version}"

  payment_endpoint = "${var.prefix}-payment.${var.domain}"
  products_endpoint = "${var.prefix}-products.${var.domain}"
}