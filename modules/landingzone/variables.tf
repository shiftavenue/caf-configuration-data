variable "default_location" {
  type        = string
  default     = "westeurope"
  description = "Default location for resources."
}

variable "root_id" {
  type        = string
  default     = "shiftavenue"
  description = "Root ID that is part of all resources and can be used to discern environments."
}

variable "root_name" {
  type        = string
  default     = "shiftavenue"
  description = "Name of the root management group."
}

variable "billing_scope" {
  type        = string
  default     = ""
  description = "The billing scope to use for the subscription vending module. Not required if subscriptions are created beforehand. Format: /providers/Microsoft.Billing/billingAccounts/1234567/enrollmentAccounts/123456"
}
