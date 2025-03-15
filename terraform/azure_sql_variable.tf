variable "sql_db_admin_password" {
  type        = string
  description = "(Required) The administrator password of the SQL logical server."
  sensitive   = true
  default     = null
}