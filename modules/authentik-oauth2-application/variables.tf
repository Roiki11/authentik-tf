variable "authentik_base_url" {
  type        = string
  description = "The root URL of your Authentik instance (e.g., https://company.local)."
}

variable "apps_config" {
  type = map(object({
    name                    = string
    slug                    = string
    authorization_flow_uuid = string
    redirect_uris           = list(string)
    vault_mount             = string # The KVv2 engine mount path (e.g., "secret")
    vault_secret_name       = string # The logical name/path inside that engine (e.g., "apps/my-app")
    property_mappings       = optional(list(string), ["scope-openid", "scope-profile", "scope-email"])
  }))
  description = "A map configurations to provision multiple Authentik applications and sync them to Vault."
}
