resource "aws_lambda_function" "imagescaler" {
  filename = "../build/distributions/${local.name}-${var.version}.zip" // This would usually be passed as a variable
  function_name = "${local.name_with_prefix}"
  publish = true
  role = "arn:aws:iam::853161928370:role/S3Lambda" // This would usually be created dynamically
  handler = "de.inovex.training.whiskystore.imagescaler.ImageScaler"
  source_code_hash = "../build/distributions/${local.name}-${var.version}.zip" // This would usually be passed as a variable
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
  bucket = "${var.prefix}-whiskystore-images"
  lambda_function {
    lambda_function_arn = "${aws_lambda_function.imagescaler.arn}"
    events = ["s3:ObjectCreated:*"]
    filter_prefix = "inbox/"
  }
}