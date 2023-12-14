variable "region" {
  description = "This is the cloud hosting region where the webapp will be deployed."
}

variable "prefix" {
  description = "This is the environment where the webapp is deployed."
}
variable "profile" {
  description = "This is the user profile for aws cred"
}

variable "s3_bucket" {
  description = "s3 bucket to store lambda function code"
  default     = "ecafe-resources-dev"
}