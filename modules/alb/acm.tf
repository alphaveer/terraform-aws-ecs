resource "aws_acm_certificate" "main" {
  domain_name               = var.dmain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"
}

data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "main" {
  name    = "${element(split(".shanux.com.", aws_acm_certificate.main.domain_validation_options.0.resource_record_name), 0)}"
  type    = "${aws_acm_certificate.main.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.main.id}"
  records = ["${aws_acm_certificate.main.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = "${aws_acm_certificate.main.arn}"
  validation_record_fqdns = ["${aws_route53_record.main.fqdn}"]
}
