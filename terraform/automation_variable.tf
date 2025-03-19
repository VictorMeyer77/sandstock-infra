variable "aut_github_repository" {
  type        = string
  description = "(Required) Name of Github Runbooks repository."
}

variable "aut_github_token" {
  type        = string
  description = "(Required) Token of Github Runbooks repository."
  sensitive   = true
}