variable "prefix" {}

variable "version" {
  default = "UNSET"
}

variable "domain" {
  default = "cdt.whatsop.io"
}

variable "postgresql" {
  type = "map"
  default = {
    user = "ordersadmin"
    password = "rS290158WoZ21U56q5vc"
  }
}