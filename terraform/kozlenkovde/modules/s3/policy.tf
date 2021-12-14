# Creates policy to allow public access to the S3 bucket
resource "aws_s3_bucket_policy" "update_bucket_root_bucket_policy" {
  bucket = aws_s3_bucket.main.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "PolicyForWebsiteEndpointsPublicContent",
  "Statement": [
    {
      "Sid": "PublicRead",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "${aws_s3_bucket.main.arn}/*",
        "${aws_s3_bucket.main.arn}"
      ]
    }
  ]
}
POLICY
}