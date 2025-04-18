data "azuread_application" "web_app" {
  client_id = azuread_application.web_app.client_id
}

resource "random_uuid" "widgets_scope_id" {}

resource "azuread_application" "web_app" {
  display_name     = "${var.environment}-${var.project}-wap-app"
  identifier_uris  = ["api://${var.environment}-${var.project}"]
  sign_in_audience = "AzureADMyOrg"

  api {
    requested_access_token_version = 2

    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access ${var.environment}-${var.project} on behalf of the signed-in user."
      admin_consent_display_name = "Access ${var.environment}-${var.project}"
      enabled                    = true
      id                         = random_uuid.widgets_scope_id.result
      type                       = "User"
      user_consent_description   = "Allow the application to access ${var.environment}-${var.project} on your behalf."
      user_consent_display_name  = "Access ${var.environment}-${var.project}"
      value                      = "user_impersonation"
    }
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }
  }

  web {
    homepage_url  = "https://${var.environment}-${var.project}.azurewebsites.net"
    logout_url    = "https://${var.environment}-${var.project}.azurewebsites.net/logout"
    redirect_uris = [local.erp_login_url]

    implicit_grant {
      access_token_issuance_enabled = true
      id_token_issuance_enabled     = true
    }
  }
}

resource "azuread_service_principal" "web_app_sp" {
  client_id                    = azuread_application.web_app.client_id
  app_role_assignment_required = false

  depends_on = [azuread_application_password.web_app_secret]
}

resource "time_rotating" "password_rotation" {
  rotation_days = 30
}

resource "azuread_application_password" "web_app_secret" {
  application_id = azuread_application.web_app.id
  rotate_when_changed = {
    rotation = time_rotating.password_rotation.id
  }
}
