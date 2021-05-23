# Creates bucket to store the static website
resource "aws_s3_bucket" "main" {
  bucket        = local.main
  acl      = "public-read"

  # Comment the following line if you are uncomfortable with Terraform destroying the bucket even if not empty
  force_destroy = true

  logging {
    target_bucket = aws_s3_bucket.log.bucket
    target_prefix = "${var.fqdn}/"
  }

  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  tags = {
    ManagedBy = "terraform"
    Changed   = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  }

  lifecycle {
    ignore_changes = [tags]
  }
}



