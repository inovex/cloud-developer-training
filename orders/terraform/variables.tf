variable "prefix" {}

variable "version" {
  default = "0.0.1-SNAPSHOT"
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