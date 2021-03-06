variable "bucket_site" {}

resource "aws_s3_bucket" "site_bucket" {
  bucket = "${var.bucket_site}"
  acl    = "public-read"
  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[{
    "Sid":"PublicReadForGetBucketObjects",
       "Effect":"Allow",
    "Principal": "*",
     "Action":["s3:GetObject"],
     "Resource":["arn:aws:s3:::${var.bucket_site}/*"
     ]
   }
 ]
}
 EOF
  force_destroy = "true"
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}
