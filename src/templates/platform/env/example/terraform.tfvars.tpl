{% if cluster.azure_public_dns is defined %}
azure_cloud_zone       = "{{ cluster.azure_public_dns.azure_cloud_zone }}"
{% endif %}
kubernetes_version     = "{{ cluster.kubernetes_version }}"
orchestrator_version   = "{{ cluster.orchestrator_version }}"
name                   = "{{ cluster.name }}-{{ cluster.stage }}"
node_pool_count        = {{ cluster.node_pool_count }}
enable_auto_scaling    = {{ cluster.enable_auto_scaling |lower }}
node_pool_min_count    = {{ cluster.node_pool_min_count }}
node_pool_max_count    = {{ cluster.node_pool_max_count }}
vm_size                = "{{ cluster.vm_size }}"
local_account_disabled = true
load_balancer_sku      = "standard"
authorized_ip_ranges   = {{ cluster.authorized_ip_ranges | tojson }}
admin_list             = {{ cluster.admin_list | tojson }}
{% if cluster.azuread_group is defined %}
display_name           = "{{ cluster.azuread_group.name }}"
{% endif %}

{% if cluster.azuread_user is defined %}
azuread_display_name   = "{{ cluster.azuread_user.display_name }}"
azuread_user_name      = "{{ cluster.azuread_user.name }}"
mail_nickname          = "{{ cluster.azuread_user.mail_nickname }}"
{% endif %}
{% if cluster.azure_key_vault is defined %}
key_vault_name         = "{{ cluster.azure_key_vault.name }}"
{% endif %}

acr_name = "{{ cluster.acr.name }}"

{% if cluster.node_pools is defined %}
enable_node_pools    = "{{ cluster.node_pools.enable_node_pools |lower }}"

node_pools = {
{%- for pool in cluster.node_pools.pool %}
  "{{ pool.name }}" = {
    enable_auto_scaling    = false
    enable_host_encryption = false
    enable_node_public_ip  = false
    max_count              = {{ pool.max_count }}
    max_pods               = 45
    min_count              = {{ pool.min_count }}
    name                   = "{{ pool.name }}"
    node_count             = {{ pool.node_count }}
    node_labels = {}
    node_taints     = []
    os_disk_size_gb = "32"
    vm_size         = "Standard_B4ms"
    zones           = ["1"]
  }
{%- endfor %}
}

{% endif %}

tags = {
  Maintainer  = "{{ azure_tags.maintainer }}"
  Owner       = "{{ azure_tags.owner }}"
  PoC         = "AKS"
  TF-Managed  = "true"
  Environment = "{{ cluster.stage }}"
}