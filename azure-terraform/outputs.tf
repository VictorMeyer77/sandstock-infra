output "application_id" {
  value = azuread_application.app.client_id
}

output "client_secret" {
  value     = azuread_application_password.app_secret.value
  sensitive = true
}