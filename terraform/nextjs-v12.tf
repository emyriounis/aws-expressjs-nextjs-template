# resource "aws_route53_record" "cloudfront_alias_domain" {
#   depends_on = [module.nextjs_v12_cloudfront_certificate]

#   zone_id = data.aws_route53_zone.base_domain.zone_id
#   name    = local.nextjs_v12_domain
#   type    = "A"

#   alias {
#     name                   = module.nextjs_v12.cloudfront_domain_name
#     zone_id                = module.nextjs_v12.cloudfront_hosted_zone_id
#     evaluate_target_health = true
#   }
# }

# resource "aws_route53_record" "nextjs_v12_domain_validation" {
#   depends_on = [module.nextjs_v12_cloudfront_certificate]

#   for_each = {
#     for dvo in module.nextjs_v12_cloudfront_certificate.acm_certificate_domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = data.aws_route53_zone.base_domain.zone_id
# }

# module "nextjs_v12_cloudfront_certificate" {
#   source  = "terraform-aws-modules/acm/aws"
#   version = "4.3.2"

#   domain_name = local.nextjs_v12_domain
#   zone_id     = data.aws_route53_zone.base_domain.zone_id

#   providers = {
#     aws = aws.global_region
#   }
# }

# module "nextjs_v12" {
#   source  = "milliHQ/next-js/aws"
#   version = "0.13.2"

#   providers = {
#     aws.global_region = aws.global_region
#   }

#   deployment_name = local.repo
#   next_tf_dir     = "../nextjs-v12/.next-tf"

#   cloudfront_aliases             = [local.nextjs_v12_domain]
#   cloudfront_acm_certificate_arn = module.nextjs_v12_cloudfront_certificate.acm_certificate_arn

#   expire_static_assets         = 7
#   lambda_memory_size           = var.lambda_memory_size
#   lambda_runtime               = var.runtime
#   use_awscli_for_static_upload = true

#   # lambda_environment_variables = {
#   #   key = "value"
#   # }
# }
