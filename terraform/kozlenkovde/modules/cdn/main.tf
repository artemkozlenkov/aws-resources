# Creates the CloudFront distribution to serve the static website
resource "aws_cloudfront_distribution" "website_cdn_root" {

  enabled     = true
  price_class = "PriceClass_100" # Select the correct PriceClass depending on who the CDN is supposed to serve (https://docs.aws.amazon.com/AmazonCloudFront/ladev/DeveloperGuide/PriceClass.html)
  aliases = [
    var.fqdn, "www.${var.fqdn}"
  ]

  origin {
    origin_id   = "origin-bucket-${var.bucket_root.id}"
    domain_name = var.bucket_root.website_endpoint

    custom_origin_config {
      origin_protocol_policy = "http-only" # The protocol policy that you want CloudFront to use when fetching objects from the origin server (a.k.a S3 in our situation). HTTP Only is the default setting when the origin is an Amazon S3 static website hosting endpoint, because Amazon S3 doesn’t support HTTPS connections for static website hosting endpoints.
      http_port              = 80
      https_port             = 443
      origin_ssl_protocols   = ["TLSv1.2", "TLSv1.1", "TLSv1"]
    }
  }

  default_root_object = "index.html"

  logging_config {
    bucket = var.bucket_log.bucket_domain_name
    prefix = "${var.fqdn}/"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "origin-bucket-${var.bucket_root.id}"
    min_ttl          = "0"
    default_ttl      = "300"
    max_ttl          = "1200"

    viewer_protocol_policy = "redirect-to-https" # Redirects any HTTP request to HTTPS
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.website_certificate_arn
    ssl_support_method  = "sni-only"
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_page_path    = "/index.html"
    response_code         = 200
  }

  tags = {
    ManagedBy = "terraform"
    Changed   = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  }

  lifecycle {
    ignore_changes = [
      tags,
      viewer_certificate,
    ]
  }
}

