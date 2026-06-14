locals {
  resource_prefix = "${var.name}-${var.environment}"

  env_prefix = var.environment == "prod" ? "" : "${var.environment}."
  subdomain  = "${local.env_prefix}${var.name}.${var.base_domain}"

  reactjs_domain = "reactjs.${local.subdomain}"
}
