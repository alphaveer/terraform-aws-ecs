resource "aws_acm_certificate" "main" {
  count                     = var.ssl_certificate_arn == null ? 1 : 0
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"
}

data "aws_route53_zone" "main" {
  count        = var.ssl_certificate_arn == null ? 1 : 0
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "main" {
  count   = var.ssl_certificate_arn == null ? 1 : 0
  name    = element(split(var.domain_name, aws_acm_certificate.main[0].domain_validation_options.0.resource_record_name), 0)
  type    = aws_acm_certificate.main[0].domain_validation_options.0.resource_record_type
  zone_id = data.aws_route53_zone.main[0].id
  records = [ aws_acm_certificate.main[0].domain_validation_options.0.resource_record_value ]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "main" {
  count                   = var.ssl_certificate_arn == null ? 1 : 0
  certificate_arn         = aws_acm_certificate.main[0].arn
  validation_record_fqdns = [ aws_route53_record.main[0].fqdn ]
}
