
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
  }
}



resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "ECafeOrderProcessor-${var.prefix}"
  role_arn = aws_iam_role.StateMachineRole.arn
   definition = templatefile("../workflow/OrderProcessorWorkflow.asl.json", {
getStoreStatus = var.get_store_status_arn
getStoreCapacity = var.get_store_capacity_arn

  })
  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.OrderProcessorStateMachine.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }
}

# Create an IAM role for the Step Functions state machine
data "aws_iam_policy_document" "state_machine_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

resource "aws_iam_role" "StateMachineRole" {
  name               = "ECafeOrderProcessor-${var.prefix}"
  assume_role_policy = data.aws_iam_policy_document.state_machine_assume_role_policy.json
}

data "aws_iam_policy_document" "state_machine_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData",
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction"
    ]

    resources = ["*"]
  }

}

# Create an IAM policy for the Step Functions state machine
resource "aws_iam_role_policy" "StateMachinePolicy" {
  role   = aws_iam_role.StateMachineRole.id
  policy = data.aws_iam_policy_document.state_machine_role_policy.json
}

# Create a Log group for the state machine
resource "aws_cloudwatch_log_group" "OrderProcessorStateMachine" {
  name_prefix       = "OrderProcessorStateMachine"
  retention_in_days = 1
}