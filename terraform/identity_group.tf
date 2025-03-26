# Web applications group

resource "azuread_group" "web_app_grp" {
  display_name            = "${var.environment}-${var.project}-grp-web-app"
  description             = "User group for accessing web applications."
  owners                  = [data.azuread_client_config.current.object_id]
  security_enabled        = true
  prevent_duplicate_names = true
}

resource "azuread_group_member" "web_app_grp_usr" {
  for_each         = azuread_user.web_app_usr
  group_object_id  = azuread_group.web_app_grp.object_id
  member_object_id = each.value.object_id
}

resource "azuread_group_member" "web_app_grp_inv" {
  for_each         = azuread_invitation.ad_inv
  group_object_id  = azuread_group.web_app_grp.object_id
  member_object_id = each.value.user_id
}