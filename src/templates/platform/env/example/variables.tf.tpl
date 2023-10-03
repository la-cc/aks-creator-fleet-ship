variable "name" {
  type    = string
}

variable "orchestrator_version" {

  type    = string
  default = "1.24.9"
  description = <<-EOT

  (Optional) Version of Kubernetes used for the Agents.
  If not specified, the default node pool will be created with the version specified by kubernetes_version.
  If both are unspecified, the latest recommended version will be used at provisioning time (but won't auto-upgrade).
  AKS does not require an exact patch version to be specified, minor version aliases such as 1.22 are also supported.
  The minor version's latest GA patch is automatically chosen in that case. More details can be found in

  EOT
}

variable "kubernetes_version" {
  type    = string
  default = "1.24.9"
  description = <<-EOT

  (Optional) Version of Kubernetes specified when creating the AKS managed cluster.
  If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade).
  AKS does not require an exact patch version to be specified, minor version aliases such as 1.22 are also supported.
  The minor version's latest GA patch is automatically chosen in that case.

  EOT
}

variable "location" {
  type    = string
  default = "westeurope"
  description = "(Required) The location where the Managed Kubernetes Cluster should be created. Changing this forces a new resource to be created."

}

variable "enable_aad_rbac" {
  type        = bool
  default     = true
  description = "Is Role Based Access Control based on Azure AD enabled?"

}

variable "admin_list" {
  type        = list(string)
  default     = []
  description = "If rbac is enabled, the default admin will be set over aad groups"

}

variable "local_account_disabled" {
  type        = bool
  default     = false
  description = <<-EOT
  If true local accounts will be disabled. Defaults to false.
  When deploying an AKS Cluster, local accounts are enabled by default.
  Even when enabling RBAC or Azure Active Directory integration, --admin access still exists, essentially as a non-auditable backdoor option.
  With this in mind, AKS offers users the ability to disable local accounts via a flag, disable-local-accounts.
  A field, properties.disableLocalAccounts, has also been added to the managed cluster API to indicate whether the feature has been enabled on the cluster.
  See the documentation for more information:  https://docs.microsoft.com/azure/aks/managed-aad#disable-local-accounts"
  EOT
}

variable "authorized_ip_ranges" {

  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = <<-EOT
    Set of authorized IP ranges to allow access to API server, e.g. ["198.51.100.0/24"].
    EOT
}

variable "load_balancer_sku" {
  type        = string
  default     = "basic"
  description = "Specifies the SKU of the Load Balancer used for this Kubernetes Cluster. Possible values are basic and standard. Defaults to standard"
}

{% if cluster.azure_public_dns is defined %}
variable "azure_cloud_zone" {

  type    = string

}
{% endif %}

variable "vm_size" {

  type    = string
  default = "Standard_B4ms"
  description = "(Required) The size of the Virtual Machine, such as Standard_DS2_v2"

}

variable "max_pods_per_node" {
  type    = number
  default = 45
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
}

variable "lock_name" {
  type        = string
  description = "Specifies the name of the Management Lock. Changing this forces a new resource to be created."
  default     = "delete lock on resource-group-level"
}

variable "lock_level" {
  type        = string
  description = "Specifies the Level to be used for this Lock. Possible values are CanNotDelete and ReadOnly. Changing this forces a new resource to be created."
  default     = "CanNotDelete"
}

variable "notes" {
  type        = string
  description = "Specifies some notes about the lock. Maximum of 512 characters. Changing this forces a new resource to be created."
  default     = "Locked, if you want remove the resourcegroup or a resource in this group, you must delete the lock first"
}

variable "network_plugin" {

  type    = string
  default = "azure"
  description = "(Required) Network plugin to use for networking. Currently supported values are azure, kubenet and none. Changing this forces a new resource to be created."

}

variable "network_policy" {

  type    = string
  default = "calico"
  description = "(Optional) Sets up network policy to be used with Azure CNI. Network policy allows us to control the traffic flow between pods. Currently supported values are calico and azure. Changing this forces a new resource to be created."
}

variable "node_pool_profile_name" {
  type        = string
  default     = "default"
  description = "The name which should be used for the default Kubernetes Node Pool. Changing this forces a new resource to be created."
}

variable "enable_auto_scaling" {
  type        = bool
  default     = false
  description = "Should the Kubernetes Auto Scaler be enabled for this Node Pool? Defaults to false."
}

variable "node_pool_count" {
  type        = number
  default     = 3
  description = <<-EOT
    If enable_auto_scaling is set to true, this variable:
        - is optional.
        - specifies the initial number of nodes which should exist in the Node Pool.

    If enable_auto_scaling is set to false, this variable:
        - is required.
        - specifies the fixed number of nodes which should exist in the Node Pool.
    EOT
}

variable "node_pool_min_count" {
  type        = number
  default     = 2
  description = <<-EOT
    If enable_auto_scaling is set to true, this variable:
        - is required.
        - specifies the minimum number of nodes which should exist in the Node Pool.

    If enable_auto_scaling is set to false, this variable should not be set.
    EOT
}

variable "node_pool_max_count" {
  type        = number
  default     = 5
  description = <<-EOT
    If enable_auto_scaling is set to true, this variable:
        - is required.
        - specifies the maximum number of nodes which should exist in the Node Pool.

    If enable_auto_scaling is set to false, this variable should not be set.
    EOT
}


variable "enable_node_pools" {

  type        = bool
  default     = false
  description = "Allow you to enable node pools"

}


variable "node_pools" {
  type = map(object({
    name                   = string
    vm_size                = string
    zones                  = list(string)
    enable_auto_scaling    = bool
    enable_host_encryption = bool
    enable_node_public_ip  = bool
    max_pods               = number
    node_labels            = map(string)
    node_taints            = list(string)
    os_disk_size_gb        = string
    max_count              = number
    min_count              = number
    node_count             = number
  }))

  description = <<-EOT
    If the default node pool is a Virtual Machine Scale Set, you can define additional node pools by defining this variable.
    As of Terraform 1.0 it is not possible to mark particular attributes as optional. If you don't want to set one of the attributes, set it to null.
  EOT

  default = {}
}


variable "tags" {
  type = map(string)
  default = {
    TF-Managed  = "true"
    Maintainer  = "HPA"
    TF-Worfklow = ""
    Owner       = "HSA"
    PoC         = "AKS"
  }
}

{% if cluster.azuread_user is defined %}
########## Azure AD User ##########
variable "azuread_user_name" {

  type        = string
  description = "value of the user name"

}

variable "azuread_display_name" {

  type        = string
  description = "value of the display name"
}

variable "mail_nickname" {

  type        = string
  description = "value of the mail nickname"

}
{% endif %}

########## Azure AD Group ##########
variable "display_name" {
  type        = string
  default     = ""
  description = "display_name - (Required) The display name for the group."
}
variable "owners" {
  type        = list(string)
  default     = []
  description = <<-EOT
    (Optional) A set of object IDs of principals that will be granted ownership of the group.
    Supported object types are users or service principals.
    By default, the principal being used to execute Terraform is assigned as the sole owner.
    Groups cannot be created with no owners or have all their owners removed.
  EOT
}
variable "members" {
  type        = list(string)
  default     = []
  description = <<-EOT
     (Optional) A set of members who should be present in this group.
     Supported object types are Users, Groups or Service Principals.
     Cannot be used with the dynamic_membership block.
  EOT
}

########## Azure Container Registries ##########

variable "sku" {

  type    = string
  default = "Premium"
  description = "(Required) The SKU name of the container registry. Possible values are Basic, Standard and Premium."
}

variable "admin_enabled" {

  type    = bool
  default = false
  description = " (Optional) Specifies whether the admin user is enabled. Defaults to false."
}


variable "acr_name" {

  type        = string
  description = "(Required) Specifies the name of the container registry. Changing this forces a new resource to be created."
}


########## Azure Key Vault ##########

variable "network_acls" {

  type = object({
    bypass                     = string,
    default_action             = string,
    ip_rules                   = list(string),
    virtual_network_subnet_ids = list(string),
  })

  default = {
    bypass                     = "AzureServices"
    default_action             = "Allow"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }

  description = "(Optional) A network_acls block as defined below"

}

variable "key_vault_admin_object_ids" {
  type        = list(string)
  description = "Optional list of object IDs of users or groups who should be Key Vault Administrators. Should only be set, if enable_rbac_authorization is set to true."
  default     = []
}

variable "role_definition_name" {
  type        = string
  description = "The Scoped-ID of the Role Definition. Changing this forces a new resource to be created. Conflicts with role_definition_name"
  default     = "Key Vault Administrator"
}

variable "enable_rbac_authorization" {
  type        = bool
  description = "Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions."
  default     = true
}

variable "key_vault_name" {
  type        = string
  description = "Specifies the name of the Key Vault. Changing this forces a new resource to be created."
}
{% if cluster.grafana_aad_app is defined %}
########## Azure AD Grafana Enterprise App + App Registration ##########
variable "grafana_aad_app" {
  type = map(object({
    display_name                 = string
    redirect_uris                = list(string)
    logout_url                   = string
    app_role_assignment_required = bool
    app_owners                   = list(string)
    roles = map(object({
      app_role_id         = string
      principal_object_id = string
    }))

  }))

  default = {}
}


variable "grafana_app_roles" {
  type = map(object({
    allowed_member_types = list(string)
    description          = string
    display_name         = string
    enabled              = bool
    id                   = string
    value                = string


  }))
  default = {

    "grafana_viewer" = {
      allowed_member_types = ["User"]
      description          = "Grafana read only Users"
      display_name         = "Grafana Viewer"
      enabled              = true
      id                   = "5ece0e92-30f6-4c31-8c94-e7195c20f668"
      value                = "Viewer"
    },

    "grafana_editor" = {
      allowed_member_types = ["User"]
      description          = "Grafana Editor Users"
      display_name         = "Grafana Editor"
      enabled              = true
      id                   = "2b2d3ad4-1c78-45db-a077-909f755c36aa"
      value                = "Editor"
    },

    "grafana_admin" = {
      allowed_member_types = ["User"]
      description          = "Grafana admin Users"
      display_name         = "Grafana Admin"
      enabled              = true
      id                   = "e15be93c-edc1-4b89-ad19-c5f143de6ebd"
      value                = "Admin"
    }

  }

  description = <<-EOT
    List of app_roles to configure app_role in for a aad application.

    Example:

    default = {

      "grafana_viewer" = {
        allowed_member_types = ["User"]
        description          = "Grafana read only Users"
        display_name         = "Grafana Viewer"
        enabled              = true
        id                   = "5ece0e92-30f6-4c31-8c94-e7195c20f668"
        value                = "Viewer"
      },

      "grafana_editor" = {
        allowed_member_types = ["User"]
        description          = "Grafana Editor Users"
        display_name         = "Grafana Editor"
        enabled              = true
        id                   = "2b2d3ad4-1c78-45db-a077-909f755c36aa"
        value                = "Editor"
      }

    }

   Explanation:
   A collection of app_role blocks as documented below. For more information see official documentation on Application Roles.

  EOT
}
{% endif %}