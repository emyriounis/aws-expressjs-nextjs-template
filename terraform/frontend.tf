resource "aws_route53_record" "cloudfront_alias_domain" {
  depends_on = [module.frontend_cloudfront_certificate]

  zone_id = data.aws_route53_zone.base_domain.zone_id
  name    = local.subdomain
  type    = "A"

  alias {
    name                   = module.frontend_next.cloudfront_domain_name
    zone_id                = module.frontend_next.cloudfront_hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "validation_subdomain" {
  depends_on = [module.frontend_cloudfront_certificate]

  for_each = {
    for dvo in module.frontend_cloudfront_certificate.acm_certificate_domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.base_domain.zone_id
}

module "frontend_cloudfront_certificate" {
  source  = "terraform-aws-modules/acm/aws"
  version = "4.3.2"

  domain_name = local.subdomain
  zone_id     = data.aws_route53_zone.base_domain.zone_id

  providers = {
    aws = aws.global_region
  }
}

module "frontend_next" {
  source  = "milliHQ/next-js/aws"
  version = "0.13.2"

  providers = {
    aws.global_region = aws.global_region
  }

  deployment_name = local.repo
  next_tf_dir     = "../frontend/.next-tf"

  cloudfront_aliases             = [local.subdomain]
  cloudfront_acm_certificate_arn = module.frontend_cloudfront_certificate.acm_certificate_arn

  expire_static_assets         = 7
  lambda_memory_size           = var.lambda_memory_size
  lambda_runtime               = var.runtime
  use_awscli_for_static_upload = true

  # lambda_environment_variables = {
  #   key = "value"
  # }
}
