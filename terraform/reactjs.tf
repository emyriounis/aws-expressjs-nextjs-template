module "reactjs_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket                   = "${local.repo}-reactjs"
  object_ownership         = "ObjectWriter"
  acl                      = "private"
  force_destroy            = true
  control_object_ownership = true

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "reactjs_static_files" {
  source  = "hashicorp/dir/template"
  version = "1.0.2"

  base_dir = "../reactjs/build"
}

resource "aws_s3_object" "reactjs_files" {
  bucket   = module.reactjs_bucket.s3_bucket_id
  for_each = module.reactjs_static_files.files

  key          = each.key
  source       = each.value.source_path
  content      = each.value.content
  content_type = each.value.content_type
  etag         = each.value.digests.md5
}

resource "aws_cloudfront_origin_access_identity" "reactjs_oai" {}

resource "aws_cloudfront_distribution" "reactjs_distribution" {
  origin {
    domain_name = module.reactjs_bucket.s3_bucket_bucket_regional_domain_name
    origin_id   = aws_cloudfront_origin_access_identity.reactjs_oai.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.reactjs_oai.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases             = [local.reactjs_domain]
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_cloudfront_origin_access_identity.reactjs_oai.id

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  ordered_cache_behavior {
    path_pattern     = "/index.html"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = aws_cloudfront_origin_access_identity.reactjs_oai.id

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn      = module.reactjs_cloudfront_certificate.acm_certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  # custom_error_response {
  #   error_caching_min_ttl = 300
  #   error_code            = 403
  #   response_code         = 200
  #   response_page_path    = "/index.html"
  # }

  # custom_error_response {
  #   error_caching_min_ttl = 300
  #   error_code            = 404
  #   response_code         = 200
  #   response_page_path    = "/index.html"
  # }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

data "aws_iam_policy_document" "reactjs_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.reactjs_bucket.s3_bucket_arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.reactjs_oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "reactjs_bucket_policy" {
  bucket = module.reactjs_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.reactjs_s3_policy.json
}

module "reactjs_cloudfront_certificate" {
  source  = "terraform-aws-modules/acm/aws"
  version = "4.3.2"

  domain_name = local.reactjs_domain
  zone_id     = data.aws_route53_zone.base_domain.zone_id

  providers = {
    aws = aws.global_region
  }
}

resource "aws_route53_record" "reactjs_domain" {
  depends_on = [module.reactjs_cloudfront_certificate]

  for_each = {
    for dvo in module.reactjs_cloudfront_certificate.acm_certificate_domain_validation_options : dvo.domain_name => {
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

resource "aws_route53_record" "reactjs_alias" {
  zone_id = data.aws_route53_zone.base_domain.zone_id
  name    = local.reactjs_domain
  type    = "A"

  allow_overwrite = true

  alias {
    name                   = aws_cloudfront_distribution.reactjs_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.reactjs_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
