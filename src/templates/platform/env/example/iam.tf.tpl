resource "azurerm_role_assignment" "dns_zone_contributor" {
  scope                = data.azurerm_resource_group.main.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = data.azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id

  depends_on = [
    module.kubernetes
  ]
}
#assign network contributor role to  enterprise-application on main-rg (rg-project-stage)
resource "azurerm_role_assignment" "main_rg_ea_network_contributor" {
  scope                = data.azurerm_resource_group.main.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azurerm_kubernetes_cluster.main.identity[0].principal_id

  depends_on = [
    module.kubernetes
  ]
}

#assign network contributor role to  managed identity  on main-rg (rg-project-stage)
resource "azurerm_role_assignment" "main_mi_network_contributor" {
  scope                = data.azurerm_resource_group.main.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id

  depends_on = [
    module.kubernetes
  ]
}

{% if cluster.acr is defined %}
resource "azurerm_role_assignment" "acr_pull" {
  principal_id                     = data.azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = module.acr.id
  skip_service_principal_aad_check = true
}
{% endif %}

{% if cluster.azure_key_vault is defined %}
resource "azurerm_role_assignment" "key_vault_officer" {

  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

resource "azurerm_role_assignment" "key_vault_officer_sp" {

  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azuread_service_principal.devops_terraform_cicd.object_id
}
{% endif %}


{% if cluster.azuread_group is defined %}
resource "azurerm_role_assignment" "key_vault_admin" {

  scope                = module.key_vault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azuread_group.main.object_id
}

resource "azurerm_role_assignment" "kubernetes_admin" {

  scope                = data.azurerm_kubernetes_cluster.main.id
  role_definition_name = "Azure Kubernetes Service RBAC Admin"
  principal_id         = data.azuread_group.main.object_id
}

resource "azurerm_role_assignment" "resource_group_reader" {

  scope                = module.resource_group_platform.id
  role_definition_name = "Reader"
  principal_id         = data.azuread_group.main.object_id

}
resource "azurerm_role_assignment" "resource_group_infra_reader" {

  scope                = module.resource_group_infra.id
  role_definition_name = "Reader"
  principal_id         = data.azuread_group.main.object_id

}

{% endif %}
