from schema import Schema, Optional

config_schema = Schema({

    Optional("azure_backend"): {
        Optional("resource_group_name"): str,
        Optional("storage_account_name"): str,

    },
    Optional("azuread_group"): {
        Optional("name", default="DevOps AAD Group"): str,
        Optional("owners", default=[]): list,
        Optional("members", default=[]): list,
    },

    Optional("key_vault"): {
        Optional("git_repo_url"): str,
        Optional("service_principal_name"): str,
        Optional("svc_user_pw_name"): str,
        Optional("name"): str,
        Optional("admin_object_ids"): {

            Optional("ID"): str,
            Optional("name"): str,
        }
    },
    Optional("azuread_user"): {
        Optional("name"): str,
        Optional("display_name"): str,
        Optional("mail_nickname"): str,
    },
    Optional("acr"): {
        Optional("name"): str,
    },

    Optional("azure_tags"): {
        Optional("maintainer", default="Platform Team"): str,
        Optional("owner", default="Platform Team"): str,

    },

    "clusters": [
        {
            "name": str,
            "stage": str,
            Optional("admin_list", default=[]): list,
            # default node-pool
            Optional("node_pool_count", default=3): int,
            Optional("enable_auto_scaling", default=False): bool,
            Optional("node_pool_min_count", default=2): int,
            Optional("node_pool_max_count", default=5): int,
            Optional("vm_size", default="Standard_B4ms"): str,
            Optional("kubernetes_version", default="1.24.9"): str,
            Optional("orchestrator_version", default="1.24.9"): str,
            # additional node-pools
            Optional("node_pools"): {
                Optional("pool"): [
                    {
                        Optional("name"): str,
                        Optional("min_count"): int,
                        Optional("max_count"): int,
                        Optional("node_count"): int,
                    }
                ]
            },
            Optional("azure_public_dns"): {
                Optional("azure_cloud_zone"): str,
            },
        }
    ],

    Optional("azure_devops_pipeline"): {
        Optional("library_group"): str,

    }
})
