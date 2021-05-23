provider "aws" {
  region = var.aws_region
}

# Route 53 hosted zone
data "aws_route53_zone" "main" {
  name         = var.fqdn
  private_zone = false
}

# s3 buckets module
module "s3_buckets" {
  source = "./modules/s3"
  fqdn = var.fqdn
}

# acm module
module "acm" {
  source = "./modules/acm"
  fqdn   = var.fqdn
}

# cdn module
module "cdn" {
  source        = "./modules/cdn"
  fqdn          = var.fqdn

  bucket_root     = module.s3_buckets.bucket_main
  bucket_log      = module.s3_buckets.bucket_log

  acm = module.acm
}

# route53 module
module "route53" {
  source = "./modules/route53"
  fqdn          = var.fqdn

  website_cdn_root        = module.cdn.cdn_root
}
