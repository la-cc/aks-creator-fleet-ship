module "resource_group_platform" {
  source = "github.com/Hamburg-Port-Authority/terraform-azure-resource-group?ref=1.0.0"

  name     = format("rg-%s-%s", var.name, "platform")
  location = var.location
  tags     = var.tags

}


module "network" {
  source = "github.com/Hamburg-Port-Authority/terraform-azure-network?ref=1.0.0"

  resource_group_name           = module.resource_group_platform.name
  name                          = format("vnet-%s", var.name)
  virtual_network_address_space = ["10.0.0.0/8"]
  tags                          = var.tags

  depends_on = [
    module.resource_group_platform
  ]

}

module "kubernetes" {
  source = "github.com/Hamburg-Port-Authority/terraform-azure-kubernetes?ref=1.6.0"

  aks_name               = format("aks-%s", var.name)
  resource_group_name    = module.resource_group_platform.name
  location               = module.resource_group_platform.location
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
  node_pool_max_surge    = var.node_pool_max_surge
  azure_policy_enabled   = var.azure_policy_enabled
  network_policy         = var.network_policy
  network_plugin         = var.network_plugin
  enable_node_pools      = var.enable_node_pools
  node_pools             = var.node_pools
  local_account_disabled = var.local_account_disabled
  enable_aad_rbac        = var.enable_aad_rbac
  admin_list             = var.admin_list
  load_balancer_sku      = var.load_balancer_sku
  authorized_ip_ranges   = var.authorized_ip_ranges
  tags                   = var.tags

  depends_on = [
    module.resource_group_platform
  ]


}



module "resource_group_infra" {
  source = "github.com/Hamburg-Port-Authority/terraform-azure-resource-group?ref=1.0.0"

  name     = format("rg-%s-%s", var.name, "infrastructure")
  location = var.location
  tags     = var.tags

}

{% if cluster.azure_key_vault is defined %}
module "key_vault" {
  source = "github.com/Hamburg-Port-Authority/terraform-azure-key-vault?ref=1.0.0"

  name                       = var.key_vault_name
  resource_group_name        = module.resource_group_infra.name
  network_acls               = var.network_acls
  enable_rbac_authorization  = var.enable_rbac_authorization
  key_vault_admin_object_ids = [data.azuread_group.it_adm.object_id]

  depends_on = [
    module.resource_group_infra
  ]

}
{% endif %}

{% if cluster.acr is defined %}
module "acr" {
  source = "github.com/Hamburg-Port-Authority/terraform-azure-acr?ref=1.0.1"

  name                = var.acr_name
  resource_group_name = module.resource_group_infra.name
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  tags = var.tags

  depends_on = [
    module.resource_group_infra
  ]

}
{% endif %}

{% if cluster.azure_vm is defined %}
module "bastion_vm" {
  source = "github.com/Hamburg-Port-Authority/terraform-azure-bastion-vm?ref=1.1.0"

  resource_group_name = module.resource_group_infra.name
  name                = format("vm-%s", var.name)

  depends_on = [
    module.resource_group_infra
  ]

}
{% endif %}