# aws_s3_bucket
resource "aws_s3_bucket" "app" {
  bucket        = local.s3_bucket_name
  force_destroy = true

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-app" })
}

# aws_s3_bucket_policy
resource "aws_s3_bucket_policy" "web_bucket" {
  bucket = aws_s3_bucket.app.bucket
  policy = <<POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "AWS": "${data.aws_elb_service_account.root.arn}"
          },

          "Action": "s3:PutObject",
          "Resource": "arn:aws:s3:::${aws_s3_bucket.app.bucket}/alb-logs/*"
        },
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "delivery.logs.amazonaws.com"
          },

          "Action": "s3:PutObject",
          "Resource": "arn:aws:s3:::${aws_s3_bucket.app.bucket}/alb-logs/*",
          
           "Condition": {
              "StringEquals": {
                "s3:x-amz-acl": "bucket-owner-full-control"
               }
            }
          },
          {
            "Effect": "Allow",
            "Principal": {
              "Service": "delivery.logs.amazonaws.com"
             },

            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.app.bucket}"
          }
       ]
     }
  POLICY
}

# aws_s3_object
resource "aws_s3_object" "website_content" {
  for_each = local.website_content
  bucket   = aws_s3_bucket.app.bucket
  key      = each.value
  source   = "${path.root}/${each.value}"

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-website_content" })
}

