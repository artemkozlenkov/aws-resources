module "iam_account" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-account"
  version = "~> 3.0"

  account_alias = "iam-discourse"

  minimum_password_length = 37
  require_numbers         = false
}
