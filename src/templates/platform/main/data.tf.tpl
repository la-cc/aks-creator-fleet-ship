data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {
}

data "azuread_client_config" "current" {}


data "azurerm_resource_group" "main" {
  name = module.resource_group.name

  depends_on = [
    module.resource_group
  ]
}

data "azurerm_kubernetes_cluster" "main" {
  name                = format("aks-%s-%s", var.name, terraform.workspace)
  resource_group_name = module.resource_group.name

  depends_on = [
    module.kubernetes
  ]
}

data "azuread_group" "it43_adm" {
  object_id        = "{{ key_vault_admin_object_ids.ID }}"#{{ key_vault_admin_object_ids.name }}
  security_enabled = true

}

{% if azuread_group.enable %}
data "azuread_group" "main" {
  display_name     = var.display_name
  security_enabled = true

  depends_on = [
    azuread_group.main
  ]
}

data "azuread_users" "members" {
  user_principal_names = {{ azuread_group.members | tojson }}
}

data "azuread_users" "owners" {
  user_principal_names = {{ azuread_group.owners| tojson }}
}
{% endif %}

