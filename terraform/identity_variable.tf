variable "web_app_group_users" {
  type = list(object({
    user_principal_name = string
    display_name        = string
    mail                = string
  }))
  description = "(Optional) List of user email and display name allowed to access web applications."
  default     = []
}

variable "web_app_group_guests" {
  type        = list(string)
  description = "(Optional) List of guest email addresses allowed to access web applications."
  default     = []
}