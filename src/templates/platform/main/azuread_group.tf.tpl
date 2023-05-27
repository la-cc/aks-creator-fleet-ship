{% if azuread_group.enable %}
resource "azuread_group" "main" {
  display_name     = var.display_name
  owners           = data.azuread_users.owners.object_ids
  security_enabled = true

  members = data.azuread_users.members.object_ids
}
{% endif %}
