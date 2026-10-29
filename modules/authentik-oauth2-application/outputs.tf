output "provisioned_apps" {
  value = {
    for k, v in authentik_application.app : k => {
      application_id = v.id
      vault_version  = vault_kv_secret_v2.oauth_config[k].metadata.version
    }
  }
  description = "A mapping of the configured applications alongside their Vault secret metadata variations."
}