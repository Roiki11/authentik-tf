Example:

```
module "sso_infrastructure" {
  source = "./modules/authentik-vault"

  authentik_base_url = "https://mycompany.com"

  apps_config = {
    grafana = {
      name                    = "Grafana Production"
      slug                    = "grafana-prod"
      authorization_flow_uuid = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
      redirect_uris           = ["https://mycompany.com"]
      vault_mount             = "secret"
      vault_secret_name       = "infrastructure/grafana"
    }
    nextcloud = {
      name                    = "Nextcloud Storage"
      slug                    = "nextcloud"
      authorization_flow_uuid = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
      redirect_uris           = ["https://mycompany.com"]
      vault_mount             = "kv-apps"
      vault_secret_name       = "core/nextcloud"
      property_mappings       = ["scope-openid", "scope-profile", "scope-email", "scope-groups"]
    }
  }
}
```