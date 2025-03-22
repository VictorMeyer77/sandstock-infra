resource "azuread_application" "dbk_app" {
  display_name = "${var.environment}-${var.project}-dbk-app"
}

resource "azuread_service_principal" "dbk_app_sp" {
  client_id                    = azuread_application.dbk_app.client_id
  app_role_assignment_required = false
}

resource "azuread_service_principal_password" "dbk_app_sp_pwd" {
  display_name         = "${var.environment}-${var.project}-dbk-app-secret"
  service_principal_id = azuread_service_principal.dbk_app_sp.id
  end_date             = formatdate("YYYY-MM-DD'T'hh:mm:ss'Z'", timeadd(timestamp(), "720h")) # 30 days
}