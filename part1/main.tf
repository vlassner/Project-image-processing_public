/*
DSML3850: Cloud Computing
Instructor: Thyago Mota
Student(s): 
Description: S3 Bucket Creation and Access Configuration
*/

provider "aws" {
  region = var.region
}

/* ---------------------- *
 * Services Configuration *
 * ---------------------- */

// bucket creation 
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  force_destroy = true
}

// bucket policy
resource "aws_iam_policy" "bucket_policy" {
  name = var.bucket_policy_name
  policy = jsonencode(
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "s3:ListBucket",
                    "s3:GetObject",
                    "s3:PutObject",
                    "s3:DeleteObject"
                ],
                "Resource": [
                    "arn:aws:s3:::${var.bucket_name}",
                    "arn:aws:s3:::${var.bucket_name}/*"
                ]
            }
        ]
    })
}

/* ---------------------- *
 * Security Configuration *
 * ---------------------- */

// user creation 
resource "aws_iam_user" "user" {
  name = var.user_name
}

resource "aws_iam_access_key" "user_access_key" {
  user = aws_iam_user.user.name
}

// saving the user's credentials 
resource "local_file" "user_credentials" {
  content  = <<EOF
aws_access_key_id: ${aws_iam_access_key.user_access_key.id}
aws_secret_access_key: ${aws_iam_access_key.user_access_key.secret}
  EOF
  filename = "${path.module}/../user_credentials.txt"
}

// ataching policy to user 
resource "aws_iam_user_policy_attachment" "user_policy_attachment" {
  user       = aws_iam_user.user.name
  policy_arn = aws_iam_policy.bucket_policy.arn
}
