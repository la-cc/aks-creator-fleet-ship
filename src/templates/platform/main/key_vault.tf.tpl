resource "azurerm_key_vault_secret" "url" {
  name         = "url"
  value        = "{{ key_vault.git_repo_url }}"
  key_vault_id = module.key_vault.id
}

resource "azurerm_key_vault_secret" "private_key" {
  name         = "sshPrivateKey"
  value        = base64encode(tls_private_key.main.private_key_pem)
  key_vault_id = module.key_vault.id
}

resource "azurerm_key_vault_secret" "public_key" {
  name         = "sshpublicKey"
  value        = tls_private_key.main.public_key_openssh
  key_vault_id = module.key_vault.id
}

{% if azuread_user is defined %}
resource "azurerm_key_vault_secret" "svc_user_pw" {
  name         = "{{ key_vault.svc_user_pw_name }}"
  value        = azuread_user.svc_user.password
  key_vault_id = module.key_vault.id
}
{% endif %}

resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
