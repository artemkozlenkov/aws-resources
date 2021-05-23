output "route53_zone" {
  value = aws_route53_record.website_record
}

output "website_certificate" {
  value = aws_acm_certificate.website_certificate
}