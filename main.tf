
locals {
  no_op             = var.slack_workspace_id == "" ? true : false
  use_external_role = (var.iam_role_arn != "" && !local.no_op) ? true : false
  iam_role_arn      = local.use_external_role ? var.iam_role_arn : aws_iam_role.aws_chatbot[0].arn
  name              = lower("aws-chatbot-tf-${var.configuration_name}-${var.slack_workspace_id}")
}

output "aws_chatbot" {
  value = {
    cloudformation_id = local.no_op ? "" : aws_cloudformation_stack.aws_chatbot[0].id
    chatbot_ref       = local.no_op ? "" : aws_cloudformation_stack.aws_chatbot[0].outputs.SlackChannelConfigurationRef
  }
}

resource "aws_iam_role" "aws_chatbot" {
  count = local.use_external_role ? 0 : 1
  name  = local.name
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "chatbot.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
  ]
}

resource "aws_cloudwatch_log_group" "aws_chatbot" {
  count             = local.no_op ? 0 : 1
  name              = lower("/aws/chatbot/${var.configuration_name}")
  retention_in_days = var.chatbot_log_retention_in_days
  skip_destroy      = var.skip_destroy_log_group
}

resource "aws_cloudformation_stack" "aws_chatbot" {
  count              = local.no_op ? 0 : 1
  depends_on         = [aws_cloudwatch_log_group.aws_chatbot]
  name               = local.name
  timeout_in_minutes = var.stack_timeout
  on_failure         = var.stack_on_failure

  lifecycle {
    ignore_changes = [timeout_in_minutes]
  }

  parameters = {
    GuardrailPolicies = var.guardrail_policies
    IamRoleArn        = local.iam_role_arn
    LoggingLevel      = var.logging_level
    SlackChannelId    = var.slack_channel_id
    SnsTopicArns      = var.sns_topic_arns
    UserRoleRequired  = var.user_role_required
  }

  template_body = jsonencode(
    {
      "Parameters" : {
        "GuardrailPolicies" : {
          "Type" : "CommaDelimitedList",
        },
        "IamRoleArn" : {
          "Type" : "String",
        },
        "LoggingLevel" : {
          "Type" : "String",
        },
        "SlackChannelId" : {
          "Type" : "String",
        },
        "SnsTopicArns" : {
          "Type" : "CommaDelimitedList",
        },
        "UserRoleRequired" : {
          "Type" : "String",
        }
      },
      "Outputs" : {
        "SlackChannelConfigurationRef" : {
          "Description" : "SlackChannelConfiguration Ref",
          "Value" : { "Ref" : "SlackChannelConfiguration" }
        }
      },
      "Resources" : {
        "SlackChannelConfiguration" : {
          "Type" : "AWS::Chatbot::SlackChannelConfiguration",
          "Properties" : {
            "ConfigurationName" : var.configuration_name,
            "GuardrailPolicies" : { "Ref" : "GuardrailPolicies" }
            "IamRoleArn" : { "Ref" : "IamRoleArn" },
            "LoggingLevel" : { "Ref" : "LoggingLevel" },
            "SlackChannelId" : { "Ref" : "SlackChannelId" },
            "SlackWorkspaceId" : var.slack_workspace_id,
            "SnsTopicArns" : { "Ref" : "SnsTopicArns" },
            "UserRoleRequired" : { "Ref" : "UserRoleRequired" }
          }
        }
      }
    }
  )
}
