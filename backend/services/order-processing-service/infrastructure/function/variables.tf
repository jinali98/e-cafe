variable "source_dir" {
  description = "Path to the function code"
}


variable "output_path" {
  description = "Path to the zip file of the function code"
}

variable "s3_bucket_key" {
  description = "Key value of the S3 bucket"

}
variable "function_name" {
  description = "Name of the lambda function"

}

variable "runtime" {
  description = "Lambda function runtime"

}
variable "memory_size" {
  description = "Lambda function memory size"

}
variable "handler" {
  description = "This is the lambda function handler"

}
variable "retention_in_days" {
  description = "How many days logs are there in the cloud watch logs"

}

variable "aws_iam_role_lambda_name" {
  description = "This is the lambda role name"

}

variable "timeout" {
  description = "This is the timeout in seconds for the lambda function"

}
variable "managed_policy_name" {
  description = "This is the managed policy name for the lambda function"
}

variable "bucket_id" {
  description = "This is the s3 bucket id"
}




