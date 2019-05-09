locals {
  name             = "payment"
  name_with_prefix = "${var.prefix}-${local.name}"

  service_version = "${var.version == "UNSET" ? trimspace(file("../VERSION")) : var.version}"
}