![GitHub](https://img.shields.io/github/license/brightbock/aws-chatbot-tf) ![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/brightbock/aws-chatbot-tf) ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/brightbock/taws-chatbot-tf/Terraform)

#  AWS ChatBot Terraform

This is a Terrafrom module to configure [AWS ChatBot Slack Channels](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-chatbot-slackchannelconfiguration.html).

## How to use:

1. First you MUST add your Slack _workspace_ using the [AWS ChatBot Console](https://us-east-2.console.aws.amazon.com/chatbot/home). When the Slack workspace is listed in the AWS ChatBot Console, you can use this Terraform module to configure each channel.
   ![Slack App Permission Screenshot](https://github.com/brightbock/aws-chatbot-tf/raw/main/images/slack-permission.png)
2. Add a module definition to your Terraform. See the example below.
3. Update `sns_topic_arns`, `slack_workspace_id`, `slack_channel_id`, and any other [variables](https://github.com/brightbock/aws-chatbot-tf/blob/main/variables.tf) to match your requirements (`guardrail_policies` and `sns_topic_arns` are comma separated lists of ARNs).
4. In each private Slack channel, invite AWS ChatBot by sending a message: "@aws"


```
module "aws_chatbot" {
  source             = "git::https://github.com/brightbock/aws-chatbot-tf.git?ref=v0.1.0"
  configuration_name = "my_chatbot"
  sns_topic_arns     = "arn:aws:sns:us-west-2:000000000000:my-first-sns,arn:aws:sns:ap-northeast-3:000000000000:my-second-sns"
  slack_workspace_id = "T00000XXXXX"
  slack_channel_id   = "C00000XXXXX"
}
```

### Note:

- It seems there is no API to programatically configure ChatBot Channels, so this module achieves that by creating a CloudFormation stack.

