locals {
  name             = "orders"
  name_with_prefix = "${var.prefix}-${local.name}"

  payment_endpoint = "${var.prefix}-payment.${var.domain}"
  products_endpoint = "${var.prefix}-products.${var.domain}"
}