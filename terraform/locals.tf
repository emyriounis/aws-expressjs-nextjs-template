locals {
  repo = "${var.name}-${var.enviroment}"

  subdomain  = "${var.enviroment}.${var.name}.${var.base_domain}"
  api_domain = "api.${local.subdomain}"
}
