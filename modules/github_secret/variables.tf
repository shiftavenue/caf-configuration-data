variable "repo_name" {
  type        = string
  description = "Name of the repository to create the secrets in"
}

variable "subscription_id" {
  type        = string
  description = "Subscription ID of the UMI"
}

variable "tenant_id" {
  type        = string
  description = "Entra Tenant ID of the UMI"
}

variable "object_id" {
  type        = string
  description = "Object ID of the UMI"
}
