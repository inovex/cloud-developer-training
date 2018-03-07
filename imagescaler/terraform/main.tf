terraform {
  backend "s3" {
    region = "eu-central-1"
    bucket = "javaland-whiskystore-terraform"
    key = "imagescaler.json"
    profile = "javaland"
    workspace_key_prefix = "javaland"
  }
}

provider "aws" {
  region = "eu-central-1"
  profile = "javaland"
  version = "~> 1.9"
}

data "terraform_remote_state" "products" {
  backend = "s3"
  config {
    region = "eu-central-1"
    profile = "javaland"
    bucket = "javaland-whiskystore-terraform"
    key = "javaland/${var.prefix}/products.json"
  }
}

resource "aws_lambda_function" "imagescaler" {
  filename = "../build/distributions/imagescaler-0.0.1-SNAPSHOT.zip" // This would usually be passed as a variable
  function_name = "${var.prefix}-imagescaler"
  publish = true
  role = "arn:aws:iam::853161928370:role/S3Lambda" // This would usually be created dynamically
  handler = "de.inovex.training.whiskystore.imagescaler.ImageScaler"
  source_code_hash = "../build/distributions/imagescaler-0.0.1-SNAPSHOT.zip" // This would usually be passed as a variable
  runtime = "java8"
  memory_size = "512"
  timeout = "30"

  environment {
    variables {
      REGION = "eu-central-1"
    }
  }
}

resource "aws_lambda_permission" "with_s3" {
  statement_id = "AllowExecutionFromS3"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.imagescaler.arn}"
  principal = "s3.amazonaws.com"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${data.terraform_remote_state.products.images-s3-bucket}"
  lambda_function {
    lambda_function_arn = "${aws_lambda_function.imagescaler.arn}"
    events = ["s3:ObjectCreated:*"]
    filter_prefix = "inbox/"
  }
}