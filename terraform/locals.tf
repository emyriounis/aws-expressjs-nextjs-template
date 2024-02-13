locals {
  repo = "${var.name}-${var.enviroment}"

  env_prefix = var.enviroment == "prod" ? "" : "${var.enviroment}."
  subdomain  = "${local.env_prefix}${var.name}.${var.base_domain}"

  expressjs_domain  = "expressjs.${local.subdomain}"
  nextjs_v12_domain = "nextjs_v12.${local.subdomain}"
  nextjs_domain     = "nextjs.${local.subdomain}"
  reactjs_domain    = "reactjs.${local.subdomain}"
  vuejs_domain      = "vuejs.${local.subdomain}"
}
