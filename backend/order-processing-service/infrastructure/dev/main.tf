
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile

  default_tags {
    tags = {
      Environment = var.prefix
      Service     = "ecafe_order-processing"
    }
  }
}

terraform {
  backend "s3" {
    bucket  = "ecafe-terraform-states-dev"
    key     = "order-processor/terraform.tfstate"
    region  = "ap-south-1"
    profile = "jinali-acc-2"
  }
}

data "aws_s3_bucket" "s3_bucket" {
  bucket = var.s3_bucket
}


module "get_store_status_function" {
  source                   = "../function"
  source_dir               = "${path.root}/../../app/dist"
  output_path              = "${path.root}/../../app/main.zip"
  s3_bucket_key            = "functions/getStoreStatus/main.zip"
  function_name            = "getStoreStatus-${var.prefix}"
  runtime                  = "nodejs18.x"
  memory_size              = 128
  timeout                  = 30
  handler                  = "index.getStoreStatusHandler"
  retention_in_days        = 14
  aws_iam_role_lambda_name = "get_store_status_${var.prefix}"
  managed_policy_name      = "get_store_status_${var.prefix}"
  bucket_id                = data.aws_s3_bucket.s3_bucket.id
}

module "get_store_capacity_function" {
  source                   = "../function"
  source_dir               = "${path.root}/../../app/dist"
  output_path              = "${path.root}/../../app/main.zip"
  s3_bucket_key            = "functions/getStoreCapacity/main.zip"
  function_name            = "getStoreCapacity-${var.prefix}"
  runtime                  = "nodejs18.x"
  memory_size              = 128
  timeout                  = 30
  handler                  = "index.getStoreCapacityHandler"
  retention_in_days        = 14
  aws_iam_role_lambda_name = "get_store_capacity_${var.prefix}"
  managed_policy_name      = "get_store_capacity_${var.prefix}"
  bucket_id                = data.aws_s3_bucket.s3_bucket.id
}

module "OrderProcessorStateMachine" {
  source               = "../state-machine"
  region               = var.region
  get_store_status_arn = module.get_store_status_function.lambda_arn
  get_store_capacity_arn = module.get_store_capacity_function.lambda_arn
  prefix = var.prefix
}


