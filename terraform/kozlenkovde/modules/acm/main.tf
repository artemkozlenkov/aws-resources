# The provider below is required to handle ACM and Lambda in a CloudFront context
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

variable "fqdn" {
  type        = string
  description = "fully qualified domain name"
}

## Route 53 hosten zone
data "aws_route53_zone" "main" {
  name         = var.fqdn
  private_zone = false
}

## ACM (AWS Certificate Manager)
resource "aws_acm_certificate" "website_certificate" {
  provider = aws.us-east-1

  domain_name               = var.fqdn
  subject_alternative_names = ["*.${var.fqdn}"]
  validation_method         = "DNS"

  tags = {
    ManagedBy = "terraform"
    Changed   = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_route53_record" "website_record" {
  provider = aws.us-east-1

  for_each = {
    for dvo in aws_acm_certificate.website_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  ttl             = "60"
  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  zone_id         = data.aws_route53_zone.main.zone_id
}

# Triggers the ACM wildcard certificate validation event
resource "aws_acm_certificate_validation" "website_cert_validation" {
  provider = aws.us-east-1

  certificate_arn         = aws_acm_certificate.website_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.website_record : record.fqdn]
}

output "route53_zone" {
  value = aws_route53_record.website_record
}

output "website_certificate_arn" {
  value = aws_acm_certificate.website_certificate.arn
}
