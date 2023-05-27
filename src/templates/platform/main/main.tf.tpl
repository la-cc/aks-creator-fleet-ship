module "resource_group" {
  source = "github.com/la-cc/terraform-azure-resource-group?ref=1.0.0"

  name     = format("rg-%s-%s", var.name, terraform.workspace)
  location = var.location
  tags     = var.tags

}


module "network" {
  source = "github.com/la-cc/terraform-azure-network?ref=1.0.0"

  resource_group_name           = module.resource_group.name
  name                          = format("vnet-%s-%s", var.name, terraform.workspace)
  virtual_network_address_space = ["10.0.0.0/8"]
  tags                          = var.tags

  depends_on = [
    module.resource_group
  ]

}

module "kubernetes" {
  source = "github.com/la-cc/terraform-azure-kubernetes?ref=1.1.3"

  aks_name               = format("aks-%s-%s", var.name, terraform.workspace)
  resource_group_name    = module.resource_group.name
  location               = module.resource_group.location
  virtual_network_id     = module.network.virtual_network_id
  virtual_network_name   = module.network.virtual_network_name
  orchestrator_version   = var.orchestrator_version
  kubernetes_version     = var.kubernetes_version
  vm_size                = var.vm_size
  max_pods_per_node      = var.max_pods_per_node
  node_pool_profile_name = var.node_pool_profile_name
  enable_auto_scaling    = var.enable_auto_scaling
  node_pool_count        = var.node_pool_count
  node_pool_min_count    = var.node_pool_min_count
  node_pool_max_count    = var.node_pool_max_count
  network_policy         = var.network_policy
  network_plugin         = var.network_plugin
  enable_node_pools      = var.enable_node_pools
  node_pools             = var.node_pools
  local_account_disabled = var.local_account_disabled
  enable_aad_rbac        = var.enable_aad_rbac
  admin_list             = var.admin_list
  load_balancer_sku      = var.load_balancer_sku
  tags                   = var.tags

  depends_on = [
    module.resource_group
  ]


}



module "resource_group_infra" {
  source = "github.com/la-cc/terraform-azure-resource-group?ref=1.0.0"

  name     = format("rg-%s-%s", var.name, "infrastructure")
  location = var.location
  tags     = var.tags

}


module "key_vault" {
  source = "github.com/la-cc/terraform-azure-key-vault?ref=1.0.0"

  name                       = format("kv-%s-%s", var.name, "713")
  resource_group_name        = module.resource_group_infra.name
  network_acls               = var.network_acls
  enable_rbac_authorization  = var.enable_rbac_authorization
  key_vault_admin_object_ids = [data.azuread_group.it43_adm.object_id]

  depends_on = [
    module.resource_group_infra
  ]

}


module "acr" {
  source = "github.com/la-cc/terraform-azure-acr?ref=1.0.0"

  name                = format("acr%s", var.name)
  resource_group_name = module.resource_group_infra.name
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  tags = var.tags

  depends_on = [
    module.resource_group_infra
  ]

}
