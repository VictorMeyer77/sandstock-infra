variable "subscription_id" {
  type        = string
  description = "(Required) Azure subscription ID"
}

variable "tenant_id" {
  type        = string
  description = "(Required) Azure tenant ID"
}

variable "client_id" {
  type        = string
  description = "(Required) Azure Deploy Application client ID"
}

variable "client_secret" {
  type        = string
  description = "(Required) Azure Deploy Application client secret"
}

variable "environment" {
  type        = string
  description = "(Required) Environment name"
}

variable "project" {
  type        = string
  description = "(Required) Name of your project"
}

variable "resource_group_location" {
  type        = string
  description = "(Required) Location for the resources"
}

variable "tags" {
  type        = map(string)
  description = "(Required) Map of tags to attach to resources."
  default     = {}
}

variable "sql_db_admin_password" {
  type        = string
  description = "(Required) The administrator password of the SQL logical server."
  sensitive   = true
  default     = null
}