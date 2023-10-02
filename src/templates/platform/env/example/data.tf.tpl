data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {
}

data "azuread_client_config" "current" {}


data "azurerm_resource_group" "main" {
  name = module.resource_group_platform.name

  depends_on = [
    module.resource_group_platform
  ]
}

data "azurerm_kubernetes_cluster" "main" {
  name                = format("aks-%s", var.name)
  resource_group_name = module.resource_group_platform.name

  depends_on = [
    module.kubernetes
  ]
}

data "azuread_group" "it_adm" {
  object_id        = "{{ cluster.azure_key_vault.admin_object_ids.ID }}"#{{ cluster.azure_key_vault.admin_object_ids.name }}
  security_enabled = true

}

{% if cluster.azure_key_vault.service_principal_name is defined %}
data "azuread_service_principal" "devops_terraform_cicd" {

  display_name = "{{ cluster.azure_key_vault.service_principal_name }}"
}
{% endif %}

{% if cluster.azuread_group is defined %}
data "azuread_group" "main" {
  display_name     = var.display_name
  security_enabled = true

  depends_on = [
    azuread_group.main
  ]
}

data "azuread_users" "members" {
  user_principal_names = {{ cluster.azuread_group.members | tojson }}
}

data "azuread_users" "owners" {
  user_principal_names = {{ cluster.azuread_group.owners| tojson }}
}
{% endif %}

