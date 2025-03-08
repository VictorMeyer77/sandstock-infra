variable "subscription_id" {
  type        = string
  description = "(Required) Azure subscription ID"
}

variable "tenant_id" {
  type        = string
  description = "(Required) Azure tenant ID"
}

variable "deploy_client_id" {
  type        = string
  description = "(Required) Azure Deploy Application client ID"
}

variable "deploy_client_secret" {
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

variable "containers" {
  type        = list(string)
  description = "List of containers to create in storage"
  default     = ["raw", "bronze", "silver", "gold"]
}

variable "adf_github_account" {
  type        = string
  description = "(Required) User name of Github ADF repository."
}

variable "adf_github_repository" {
  type        = string
  description = "(Required) Name of Github ADF repository."
}