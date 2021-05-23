locals {
  redirect_fqdn = "www.${var.fqdn}"
}

## Route 53 hosten zone
data "aws_route53_zone" "main" {
  name         = var.fqdn
  private_zone = false
}

# Creates the DNS record to point on the main CloudFront distribution ID
resource "aws_route53_record" "website_cdn_root_record" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.fqdn
  type    = "A"

  alias {
    name                   = var.website_cdn_root.domain_name
    zone_id                = var.website_cdn_root.hosted_zone_id
    evaluate_target_health = false
  }
}

# Creates the DNS record to point on the CloudFront distribution ID that handles the redirection website
resource "aws_route53_record" "website_cdn_redirect_record" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = local.redirect_fqdn
  type    = "A"

  alias {
    name                   = var.website_cdn_root.domain_name
    zone_id                = var.website_cdn_root.hosted_zone_id
    evaluate_target_health = false
  }
}
