# Invitation

resource "azuread_invitation" "ad_inv" {
  for_each           = toset(var.web_app_group_guests)
  user_display_name  = each.value
  user_email_address = each.value
  redirect_url       = "https://portal.azure.com"

  message {
    language = "en-US"
  }
}

# User

resource "azuread_user" "web_app_usr" {
  for_each                    = { for idx, user in var.web_app_group_users : idx => user }
  user_principal_name         = each.value.user_principal_name
  display_name                = each.value.display_name
  mail                        = each.value.mail
  password                    = "ToCh@nge!"
  disable_password_expiration = false
  disable_strong_password     = false
}
