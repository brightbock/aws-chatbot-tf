variable "configuration_name" {
  type = string
}

variable "stack_timeout" {
  type    = string
  default = "3"
}

variable "stack_on_failure" {
  type    = string
  default = "DELETE"
}

variable "chatbot_log_retention_in_days" {
  default = "365"
  validation {
    condition     = contains(["1", "3", "5", "7", "14", "30", "60", "90", "120", "150", "180", "365", "400", "545", "731", "1827", "3653"], var.chatbot_log_retention_in_days)
    error_message = "Must be one of: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653."
  }
}

variable "guardrail_policies" {
  type    = string
  default = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

variable "iam_role_arn" {
  type    = string
  default = ""
}

variable "logging_level" {
  type    = string
  default = "ERROR"
}

variable "slack_channel_id" {
  type = string
}

variable "slack_workspace_id" {
  type = string
}

variable "sns_topic_arns" {
  type = string
}

variable "user_role_required" {
  type    = bool
  default = false
}
