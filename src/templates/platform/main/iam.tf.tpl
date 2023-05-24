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


#assign azure key-vault access policies to  managed identity (agentpool)
resource "azurerm_key_vault_access_policy" "grant_access_policy" {

  key_vault_id = module.key_vault.id
  tenant_id    = data.azuread_client_config.current.tenant_id
  object_id    = data.azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id

  certificate_permissions = var.certificate_permissions
  key_permissions         = var.key_permissions
  secret_permissions      = var.secret_permissions
  storage_permissions     = var.storage_permissions
}