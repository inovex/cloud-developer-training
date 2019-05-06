provider "aws" {
  version = "~> 1.9"
  region = "eu-central-1"
}

provider "template" {
  version = "~> 2.0"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "terraform_state_storage" {
  bucket = "${var.project}"

  acl = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags {
    Name = "Terraform State Store"
  }
}

resource "aws_s3_bucket_policy" "terraform_state_storage" {
  bucket = "${aws_s3_bucket.terraform_state_storage.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Condition": {
        "StringLike": {
          "aws:userid": [
            "${data.aws_caller_identity.current.account_id}"
          ]
        }
      },
      "Action": "s3:ListBucket",
      "Resource": "${aws_s3_bucket.terraform_state_storage.arn}"
    },
    {
      "Effect": "Allow",
      "Principal": "*",
      "Condition": {
        "StringLike": {
          "aws:userid": [
            "${data.aws_caller_identity.current.account_id}"
          ]
        }
      },
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": "${aws_s3_bucket.terraform_state_storage.arn}/**"
    }
  ]
}
POLICY
}

resource "aws_dynamodb_table" "dynamodb_terraform_state_lock" {
  name = "terraform-state-lock-${var.project}"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags {
    Name = "Terraform State Lock Table"
  }
}