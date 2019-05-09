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
    user     = "productsadmin"
    password = "BoIzqCfgjpeWVp4zeKzkf7zsbwfaqpq8ppNyvv3q"
  }
}
